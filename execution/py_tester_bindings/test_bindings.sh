#python setup.py sdist bdist_wheel
$PYBIN -m pip install wheelhouse/*.whl --force-reinstall
mkdir test
cp execution/py_tester_bindings/test_python_binding.py test/

$PYBIN test/test_python_binding.py $PYBIN $PYLIB