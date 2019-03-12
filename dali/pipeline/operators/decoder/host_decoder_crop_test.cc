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

#include "dali/pipeline/operators/decoder/decoder_test.h"

namespace dali {

template <typename ImgType>
class HostDecoderCropTest : public DecodeTestBase<ImgType> {
 protected:
  const OpSpec DecodingOp() const override {
    return this->GetOpSpec("HostDecoderCrop")
      .AddArg("crop", std::vector<float>{1.0f*crop_H, 1.0f*crop_W});
  }

  CropWindowGenerator GetCropWindowGenerator() const override {
    return [this] (int H, int W) {
      CropWindow crop_window;
      crop_window.h = crop_H;
      crop_window.w = crop_W;
      crop_window.y = 0.5f * (H - crop_window.h);
      crop_window.x = 0.5f * (W - crop_window.w);
      return crop_window;
    };
  }

  int crop_H = 224, crop_W = 200;
};

typedef ::testing::Types<RGB, BGR, Gray> Types;
TYPED_TEST_CASE(HostDecoderCropTest, Types);

TYPED_TEST(HostDecoderCropTest, JpegDecode) {
  this->Run(t_jpegImgType);
}

TYPED_TEST(HostDecoderCropTest, PngDecode) {
  this->Run(t_pngImgType);
}

TYPED_TEST(HostDecoderCropTest, TiffDecode) {
  this->crop_H = 100;
  this->crop_W = 90;
  this->Run(t_tiffImgType);
}

}  // namespace dali
