#!/bin/bash

PYBIN="/usr/bin/python3.9"
PYLIB="/usr/lib/python3.9"
rm -rf wheelhouse
bazel clean --expunge
export PYTHON_BIN_PATH=${PYBIN} && export PYTHON_LIB_PATH=${PYLIB}
$PYBIN -m pip install -r execution/py_tester_bindings/requirements.txt
rm -f bazel-bin/execution/py_tester_bindings/py_tester_extention.so
rm -f execution/py_tester_bindings/code_contests_tester/py_tester_extention.so
bazel build //execution/py_tester_bindings:py_tester_extention.so --
sudo cp bazel-bin/execution/py_tester_bindings/py_tester_extention.so execution/py_tester_bindings/code_contests_tester/


cd execution/py_tester_bindings

#pybind11-stubgen code_contests_tester

cd ../../

$PYBIN -m  pip wheel execution/py_tester_bindings       --no-deps -w wheelhouse/

#python setup.py sdist bdist_wheel
$PYBIN -m pip install wheelhouse/*.whl --force-reinstall
mkdir test
cp execution/py_tester_bindings/test_python_binding.py test/

$PYBIN test/test_python_binding.py $PYBIN $PYLIB