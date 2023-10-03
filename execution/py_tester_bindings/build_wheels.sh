#!/bin/bash
set -e -u -x

function repair_wheel {
    wheel="$1"
    if ! auditwheel show "$wheel"; then
        echo "Skipping non-platform wheel $wheel"
    else
        auditwheel repair "$wheel" --plat "$PLAT" -w /io/wheelhouse/
    fi
}


# Install a system package required by our library
yum install -y atlas-devel

# Compile wheels
for PYBIN in /opt/python/*/bin; do
    "${PYBIN}/pip" install -r /io/execution/py_tester_bindings/requirements.txt
    EXPORT PY_VERSION=$(echo "$PYBIN" | cut -d'/' -f4)
    mkdir -p execution/code_contests_tester/$PY_VERSION
    EXPORT PYTHON_BIN_PATH=${PYBIN}/python
    bazel build py_tester_extention.so --
    cp bazel-bin/execution/py_tester_extention.so execution/code_contests_tester/py_tester_extention-$PY_VERSION.so
    "${PYBIN}/pip" wheel /io/ --no-deps -w wheelhouse/
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    repair_wheel "$whl"
done

# Install packages and test
for PYBIN in /opt/python/*/bin/; do
    "${PYBIN}/pip" install code_contests_tester --no-index -f /io/wheelhouse
done