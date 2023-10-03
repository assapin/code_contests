#!/bin/bash
set -e -u -x

function repair_wheel {
    wheel="$1"
    if ! auditwheel show "$wheel"; then
        echo "Skipping non-platform wheel $wheel"
    else
        auditwheel repair "$wheel" --plat "$PLAT" -w /io/wheelhouse/fixed
    fi
}


# Install a system package required by our library
yum install -y atlas-devel

VERSIONS="cp39-cp39 cp311-cp311" # cp310-cp310 cp311-cp311 cp312-cp312"

for version in $VERSIONS; do
    PYLIB="/opt/python/${version}/lib"
    PYBIN="/opt/python/${version}/bin"
    semver=$(echo "$version" | sed -E 's/cp([0-9])([0-9]+).*/\1.\2/')

    "${PYBIN}/pip" install -r /io/execution/py_tester_bindings/requirements.txt
    export PY_VERSION=$(echo "$PYBIN" | cut -d'/' -f4)
    mkdir -p execution/code_contests_tester/$PY_VERSION
    export PYTHON_BIN_PATH=${PYBIN}/python && export PYTHON_LIB_PATH=${PYLIB}/python$semver
    rm -f bazel-bin/execution/py_tester_bindings/py_tester_extention.so
    rm -f execution/py_tester_bindings/code_contests_tester/py_tester_extention.so
    bazel build //execution/py_tester_bindings:py_tester_extention.so --repo_env PYTHON_BIN_PATH=$PYTHON_BIN_PATH --repo_env PYTHON_LIB_PATH=$PYTHON_LIB_PATH --
    cp -f bazel-bin/execution/py_tester_bindings/py_tester_extention.so execution/py_tester_bindings/code_contests_tester/
    "${PYBIN}/pip" wheel /io/execution/py_tester_bindings --no-deps -w wheelhouse/
    for file in wheelhouse/*py3-none-any.whl; do
    	mv "$file" "${file%py3-none-any.whl}$PY_VERSION-$PLAT.whl"
    done
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    repair_wheel "$whl"
done

# Install packages and test
for version in $VERSIONS; do
    PYBIN="/opt/python/${version}/bin"   
    "${PYBIN}/pip" install code_contests_tester --no-index -f /io/wheelhouse
done

