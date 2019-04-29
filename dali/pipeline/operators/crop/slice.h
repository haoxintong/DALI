// Copyright (c) 2017-2018, NVIDIA CORPORATION. All rights reserved.
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

#ifndef DALI_PIPELINE_OPERATORS_CROP_SLICE_H_
#define DALI_PIPELINE_OPERATORS_CROP_SLICE_H_

#include <utility>
#include <vector>

#include "dali/core/common.h"
#include "dali/error_handling.h"
#include "dali/pipeline/operators/common.h"
#include "dali/pipeline/operators/crop/crop.h"
#include "dali/pipeline/operators/operator.h"

namespace dali {

template <typename Backend>
class Slice : public Crop<Backend> {
 public:
  explicit inline Slice(const OpSpec &spec) : Crop<Backend>(spec) {}

 protected:
  void RunImpl(Workspace<Backend> *ws, int idx) override;

  void SetupSharedSampleParams(Workspace<Backend> *ws) override;

 private:
  void DataDependentSetup(Workspace<Backend> *ws, unsigned int idx = 0);
};

}  // namespace dali

#endif  // DALI_PIPELINE_OPERATORS_CROP_SLICE_H_
