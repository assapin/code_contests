#!/bin/bash

PYBIN="/usr/bin/python3.9"
PYLIB="/usr/lib/python3.9"
export PYTHON_BIN_PATH=${PYBIN} && export PYTHON_LIB_PATH=${PYLIB}
$PYBIN -m pip install -r execution/py_tester_bindings/requirements.txt
rm -f bazel-bin/execution/py_tester_bindings/py_tester_extention.so
rm -f execution/py_tester_bindings/code_contests_tester/py_tester_extention.so
bazel build //execution/py_tester_bindings:py_tester_extention.so --
sudo cp bazel-bin/execution/py_tester_bindings/py_tester_extention.so execution/py_tester_bindings/code_contests_tester/


pybind11-stubgen execution/py_tester_bindings/py_tester_extention.so

$PYBIN -m  pip wheel execution/py_tester_bindings 	--no-deps -w wheelhouse/

#python setup.py sdist bdist_wheel
$PYBIN -m pip pip install wheelhouse/code_contests_tester-0.1-py3-none-any.whl --force-reinstall
cp execution/py_tester_bindings/test_python_bindings.py .

$PYBIN  test_python_bindings.py /usr/bin/python3.9 /usr/lib/python3.9