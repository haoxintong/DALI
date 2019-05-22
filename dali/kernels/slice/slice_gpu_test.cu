// Copyright (c) 2019, NVIDIA CORPORATION. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <gtest/gtest.h>
#include "dali/kernels/slice/slice_kernel_test.h"
#include "dali/kernels/slice/slice_gpu.cuh"

namespace dali {
namespace kernels {

template <typename TestArgs>
class SliceGPUTest : public SliceTest<TestArgs> {
 public:
  using InputType = typename TestArgs::InputType;
  using OutputType = typename TestArgs::OutputType;
  static constexpr std::size_t Dims = TestArgs::Dims;
  static constexpr std::size_t NumSamples = TestArgs::NumSamples;
  static constexpr std::size_t DimSize = TestArgs::DimSize;
  using SliceArgsGenerator = typename TestArgs::SliceArgsGenerator;
  using KernelType = SliceGPU<OutputType, InputType, Dims>;

  void Run() override {
    KernelContext ctx;

    TestTensorList<InputType, Dims> test_data;
    this->PrepareData(test_data);

    auto slice_args = this->GenerateSliceArgs(test_data.cpu());

    KernelType kernel;
    KernelRequirements kernel_req = kernel.Setup(ctx, test_data.gpu(), slice_args);

    TensorListShape<> output_shapes = kernel_req.output_shapes[0];
    for (int i = 0; i < output_shapes.size(); i++) {
      AssertExpectedDimensions(output_shapes[i], slice_args[i].shape);
    }

    TestTensorList<OutputType, Dims> output_data;
    output_data.reshape(output_shapes.to_static<Dims>());
    OutListGPU<OutputType, Dims> out_tlv = output_data.gpu();

    kernel.Run(ctx, out_tlv, test_data.gpu(), slice_args);

    TestTensorList<OutputType, Dims> expected_output;
    this->PrepareExpectedOutput(test_data, slice_args, expected_output);

    EXPECT_NO_FATAL_FAILURE(Check(output_data.cpu(), expected_output.cpu()));
  }
};

TYPED_TEST_SUITE(SliceGPUTest, SLICE_TEST_TYPES);

TYPED_TEST(SliceGPUTest, All) {
  this->Run();
}

}  // namespace kernels
}  // namespace dali
