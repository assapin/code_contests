import os

from setuptools import setup, find_packages

py_version = os.environ.get("PY_VERSION")
setup(
    name="code_contests_tester",
    version=f"0.1.1",
    packages=find_packages(),
    setup_requires=[
        'setuptools',
        'wheel',
        'pybind11==2.11.1'
    ],
    package_data={
        'code_contests_tester': [f'py_tester_extention.so'],
    },
)

