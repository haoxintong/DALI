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

#include <vector>
#include "dali/image/transform.h"
#include "dali/kernels/slice/slice_gpu.cuh"
#include "dali/core/static_switch.h"
#include "dali/pipeline/operators/crop/new_crop.h"
#include "dali/pipeline/data/views.h"

namespace dali {

template <>
void NewCrop<GPUBackend>::SetupSharedSampleParams(DeviceWorkspace *ws) {
  CropAttr::ProcessArguments(ws);
  const auto &input = ws->Input<GPUBackend>(0);
  input_type_ = input.type().id();
  if (output_type_ == DALI_NO_TYPE)
    output_type_ = input_type_;
}

template <>
void NewCrop<GPUBackend>::DataDependentSetup(DeviceWorkspace *ws, const int idx) {
  const auto &input = ws->Input<GPUBackend>(idx);

  const DALITensorLayout in_layout = input.GetLayout();
  DALI_ENFORCE(in_layout == DALI_NHWC || in_layout == DALI_NCHW
            || in_layout == DALI_NFHWC || in_layout == DALI_NFCHW,
    "Unexpected data layout");
  DALITensorLayout out_layout = in_layout;

  for (int i = 0; i < batch_size_; ++i) {
    SetupSample(i, in_layout, input.tensor_shape(i));
  }
  auto &output = ws->Output<GPUBackend>(idx);
  output.SetLayout(out_layout);
}

template <>
void NewCrop<GPUBackend>::RunImpl(DeviceWorkspace *ws, const int idx) {
  SliceBase<GPUBackend>::RunImpl(ws, idx);
}

// Register operator
DALI_REGISTER_OPERATOR(NewCrop, NewCrop<GPUBackend>, GPU);

}  // namespace dali
