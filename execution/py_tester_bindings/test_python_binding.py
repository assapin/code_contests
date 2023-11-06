import sys
from code_contests_tester import ProgramStatus, Py3TesterSandboxer, TestOptions

program = """
x = input()
print(x)

"""


def test_binding(python_bin_path="/usr/bin/python", python_lib_path="/usr/lib/python"):
    tester = Py3TesterSandboxer(python_bin_path, python_lib_path.split(","))
    options = TestOptions()
    options.num_threads = 4
    options.stop_on_first_failure = True
    input = output = ["hello\n"]

    def compare_func(a,b):
        return a==b

    result = tester.test(program, input, options, output, compare_func)

    print(f"compilation results:{result.compilation_result.program_status}")
    print(result.compilation_result.sandbox_result)
    print(result.compilation_result.stderr)

    for i, test_res in enumerate(result.test_results):
        print(f"test-{i} :: status={test_res.program_status}, pased={test_res.passed}")
        print("=====================================================================")
        print(test_res.stdout)
        assert compare_func(test_res.stdout.strip(), output[i])
        print("=====================================================================")

if __name__ == '__main__':

    print("Usage: python3.9 test_python_binding.py <path to Python3.11 bin> <paths to Python3.11 libs with comma delimiter>")

    if not len(sys.argv) ==3:
        print("verify you've read the usage")
        exit(1)


    test_binding(sys.argv[1], sys.argv[2])



