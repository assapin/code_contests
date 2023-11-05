#!/bin/bash

PYBIN="/usr/local/bin/python"
PYLIB="/usr/local/lib/python3.9"
export PYTHON_BIN_PATH=${PYBIN} && export PYTHON_LIB_PATH=${PYLIB}
/usr/local/bin/pip install -r /io/execution/py_tester_bindings/requirements.txt
rm -f bazel-bin/execution/py_tester_bindings/py_tester_extention.so
rm -f execution/py_tester_bindings/code_contests_tester/py_tester_extention.so
bazel build //execution/py_tester_bindings:py_tester_extention.so --
cp bazel-bin/execution/py_tester_bindings/py_tester_extention.so execution/py_tester_bindings/code_contests_tester/
/usr/local/bin/pip wheel execution/py_tester_bindings 	--no-deps -w wheelhouse/


pybind11-stubgen py_tester_extention

python setup.py sdist bdist_wheel
pip install dist/code_contests_tester-0.1-py3-none-any.whl --force-reinstall

