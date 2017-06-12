/*
 Copyright 2017-present The Material Motion Authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "CalendarChipMotionSpec.h"

#define MDMEightyForty _MDMBezier(0.4f, 0.0f, 0.2f, 1.0f)
#define MDMFortyOut _MDMBezier(0.4f, 0.0f, 1.0f, 1.0f)
#define MDMEightyIn _MDMBezier(0.0f, 0.0f, 0.2f, 1.0f)
#define MDMLinear _MDMBezier(0.0f, 0.0f, 1.0f, 1.0f)

struct CalendarChipMotionSpec CalendarChipSpec = {
  .expansion = {
    .chipWidth = {
      .delay = 0.000, .duration = 0.285, .curve = MDMEightyForty,
    },
    .chipHeight = {
      .delay = 0.015, .duration = 0.360, .curve = MDMEightyForty,
    },
    .chipY = {
      .delay = 0.015, .duration = 0.360, .curve = MDMEightyForty,
    },
    .chipContentOpacity = {
      .delay = 0.000, .duration = 0.075, .curve = MDMLinear,
    },
    .headerContentOpacity = {
      .delay = 0.075, .duration = 0.150, .curve = MDMLinear,
    },
    .navigationBarY = {
      .curve = { .type = MDMMotionCurveTypeInstant },
    },
  },
  .collapse = {
    .chipWidth = {
      .delay = 0.045, .duration = 0.330, .curve = MDMEightyForty,
    },
    .chipHeight = {
      .delay = 0.000, .duration = 0.330, .curve = MDMEightyForty,
    },
    .chipY = {
      .delay = 0.015, .duration = 0.330, .curve = MDMEightyForty,
    },
    .chipContentOpacity = {
      .delay = 0.150, .duration = 0.150, .curve = MDMLinear,
    },
    .headerContentOpacity = {
      .delay = 0.000, .duration = 0.075, .curve = MDMLinear,
    },
    .navigationBarY = {
      .delay = 0.045, .duration = 0.150, .curve = MDMEightyForty,
    }
  },
};

