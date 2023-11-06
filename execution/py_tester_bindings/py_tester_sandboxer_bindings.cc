#include <pybind11/pybind11.h>
#include "execution/py_tester_sandboxer.h"
#include <pybind11/stl.h>
#include <asm/unistd.h>
#include <stdio.h>
#include <sys/syscall.h>

#include <filesystem>
#include <fstream>
#include <memory>
#include <string>
#include <type_traits>
#include <vector>

#include "absl/status/status.h"
#include "absl/status/statusor.h"
#include "absl/strings/str_cat.h"
#include "absl/strings/str_join.h"
#include "absl/strings/string_view.h"
#include "absl/time/time.h"
#include "absl/types/span.h"
#include "execution/status_macros.h"
#include "execution/temp_path.h"
#include "execution/tester_sandboxer.h"
#include "farmhash.h"
#include "sandboxed_api/sandbox2/policy.h"
#include "sandboxed_api/sandbox2/policybuilder.h"
#include "sandboxed_api/sandbox2/result.h"
#include "sandboxed_api/sandbox2/sandbox2.h"

namespace py = pybind11;
using namespace deepmind::code_contests;


class TestOptionsWrapper : public TestOptions {
public:
    using TestOptions::TestOptions; // Inherit constructors

    double get_max_execution_duration_seconds() const {
        return absl::ToDoubleSeconds(this->max_execution_duration);
    }

    void set_max_execution_duration_seconds(double seconds) {
        this->max_execution_duration = absl::Seconds(seconds);
    }
};


//class ExecutionResultWrapper : public ExecutionResult {
//public:
//    using ExecutionResult::ExecutionResult; // Inherit constructors
//
//    double get_execution_duration_seconds() const {
//        return absl::ToDoubleSeconds(this->execution_duration);
//    }
//
//    void set_execution_duration_seconds(double seconds) {
//        this->execution_duration = absl::Seconds(seconds);
//    }
//};

PYBIND11_MODULE(py_tester_extention, m) {
    m.doc() = "Python bindings for py_tester_sandboxer";
    py::register_exception_translator([](std::exception_ptr p) {
        try {
            if (p) std::rethrow_exception(p);
        } catch (const absl::Status& s) {
            if (!s.ok()) {
                throw std::runtime_error(s.ToString());
            }
        }
    });

    py::enum_<ProgramStatus>(m, "ProgramStatus")
    .value("Unknown", ProgramStatus::kUnknown)
    .value("Success", ProgramStatus::kSuccess)
    .value("Failed", ProgramStatus::kFailed)
    .value("Timeout", ProgramStatus::kTimeout)
    .export_values();

    py::class_<TestOptionsWrapper>(m, "TestOptions")
    .def(py::init<>())
    .def_readwrite("num_threads", &TestOptionsWrapper::num_threads)
    .def_readwrite("stop_on_first_failure", &TestOptionsWrapper::stop_on_first_failure)
    .def_property("max_execution_duration",
                  &TestOptionsWrapper::get_max_execution_duration_seconds,
                  &TestOptionsWrapper::set_max_execution_duration_seconds);




    py::class_<ExecutionResult>(m, "ExecutionResult")
        .def(py::init<>())
        .def_readwrite("program_status", &ExecutionResult::program_status)
        .def_readwrite("program_hash", &ExecutionResult::program_hash)
        .def_readwrite("stdout", &ExecutionResult::stdout)
        .def_readwrite("stderr", &ExecutionResult::stderr)
        //        .def_property("execution_duration",
        //                  &ExecutionResultWrapper::get_execution_duration_seconds,
        //                  &ExecutionResultWrapper::set_execution_duration_seconds);
        .def_readwrite("sandbox_result", &ExecutionResult::sandbox_result)
        .def_readwrite("passed", &ExecutionResult::passed);
        // .def("sandbox_result_status", &ExecutionResult::SandboxResultStatus);

    py::class_<MultiTestResult>(m, "MultiTestResult")
        .def(py::init<>())
        .def_readwrite("compilation_result", &MultiTestResult::compilation_result)
        .def_readwrite("test_results", &MultiTestResult::test_results);

    // Binding for Py3TesterSandboxer
    py::class_<Py3TesterSandboxer>(m, "Py3TesterSandboxer")
        .def(py::init<const std::string&, const std::vector<std::string>&>())
        .def("test", [](Py3TesterSandboxer& self,
                    const std::string& code,
                    const std::vector<std::string>& test_inputs_str,
                    const TestOptionsWrapper& test_options,
                    const std::vector<std::string>& expected_test_outputs_str,
                    py::function compare_outputs_pyfunc) {

        // Convert the test inputs from vector<string> to vector<string_view>
        std::vector<absl::string_view> test_inputs(test_inputs_str.begin(), test_inputs_str.end());

        // Convert the expected test outputs from vector<string> to vector<string_view>
        std::vector<absl::string_view> expected_test_outputs(expected_test_outputs_str.begin(), expected_test_outputs_str.end());

        // Convert py::function to std::function
        std::function<bool(std::string_view a, std::string_view b)> compare_outputs = [&compare_outputs_pyfunc](std::string_view a, std::string_view b) {
            py::gil_scoped_acquire acquire;
            return compare_outputs_pyfunc(a, b).cast<bool>();
        };
        py::gil_scoped_release release;

        absl::StatusOr<MultiTestResult> result = self.Test(code, test_inputs, test_options, expected_test_outputs, compare_outputs);

        py::gil_scoped_racquire acquire;
        if (!result.ok()) {
           throw std::runtime_error(result.status().ToString());
         }

        return result.value();
    });
}

