# Test Steps

## Table of Contents

* [Introduction](#introduction)
* [Test Step Summary](#test-step-summary)
* [Details](#details)
  * [capture_widget](#capture_widget)
  * [compare_golden_image](#compare_golden_image)
  * [hide_widget](#hide_widget)
  * [obscure_widget](#obscure_widget)


## Introduction

This plugin provides a few new [Test Steps](https://github.com/peiffer-innovations/automated_testing_framework/blob/main/documentation/STEPS.md) related to image processing.


---

## Test Step Summary

Test Step IDs                                 | Description
----------------------------------------------|-------------
[capture_widget](#capture_widget)             | Captures the image from a single widget and attaches it to the `TestReport`.
[compare_golden_image](#compare_golden_image) | Compares the image from the `TestReport` to a pre-set golden image.
[hide_widget](#hide_widget)                   | Hides or shows the widget by using transparency values.
[obscure_widget](#obscure_widget)             | Obscures or shows the widget by a colored overlay.


---
## Details


### capture_widget

**How it Works**

1. Locates the `Testable` using `testableId`; if not found by `timeout` the step fails.
2. If `backgroundColor` is set, that will be loaded into the `Testable`.
3. Captures the image for the `Testable` and stashes it using the `imageId`, or a calculated id if not set.


**Example**

```json
{
  "id": "capture_widget",
  "image": "<optional_base_64_image>",
  "values": {
    "backgroundColor": "#ff000000",
    "goldenCompatible": "true",
    "imageId": "myImageId",
    "testableId": "myTestableId",
    "timeout": "30"
  }
}
```

**Values**

Key                | Type    | Required | Supports Variable | Description
-------------------|---------|----------|-------------------|-------------
`backgroundColor`  | String  | No       | No                | The optional background color to use when capturing the image.  Useful when the background should be captured but normally comes from the parent.  Defaults to transparent.
`goldenCompatible` | boolean | No       | No                | Whether or not the image is capable of being used for golden comparisons.  Defaults to `true`.
`imageId`          | String  | No       | Yes               | Identifier for the image.  If not set, this will be an automated value based on the `testableId`.
`testableId`       | String  | Yes      | Yes               | Identifier for the `Testable`.
`timeout`          | number  | No       | Yes               | Number of seconds to wait for the `Testable` to appear on the Widget tree before failing.


---

### compare_golden_image

**How it Works**

1. Loads the appropriate golden image.
2. Immediately passes if the `disable_screen_shots` or `disable_golden_images` variable on the `TestController` is `true`.  Continues otherwise.
3. Compates the golden image to an image from the current `TestReport`.
4. Fails if the current image cannot be located.
5. Fails if it cannot load the golden image and `failWhenGoldenMissing` is `true` or omitted.
6. Fails if the golden image has more than `allowedDelta` percentage (0 to 1 based) pixels that are different.

**Example**

```json
{
  "id": "compare_golden_image",
  "image": "<optional_base_64_image>",
  "values": {
    "allowedDelta": 0.01,
    "failWhenGoldenMissing": true,
    "imageId": "myImageId",
    "imageOnFail": "isolated"
  }
}
```

**Values**

Key                     | Type    | Required | Supports Variable | Description
------------------------|---------|----------|-------------------|-------------
`allowedDelta`          | number  | No       | Yes               | 0 - 1 decimal number representing the percentage of pixels that may be different before failing.  Set to 0 to fail on a single different pixel.  Defaults to `0.01` or 1%.
`failWhenGoldenMissing` | boolean | No       | No                | Set to `true` to fail when no golden image exists for the current test image.  Set to `false` to ignore missing golden images.  Defaults to `true`.
`imageId`               | String  | No       | No                | The id of the golden image to test against.
`imageOnFail`           | String  | No       | No                | Set to `isolated` to attach an image that shows only the deltas on fail, set to `masked` to attach an image with the deltas overlayed on the golden.  Defaults to `masked`.


---

### hide_widget

**How it Works**

1. Attempts to locate the `Testable` on the widget tree using `testableId`; fails if it cannot be located by `timeout`.
2. Once located, sets the opacity to 0 if the `hide` is `true` or omitted, sets opacity to 1 if the `hide` is false.

**Example**

```json
{
  "id": "hide_widget",
  "image": "<optional_base_64_image>",
  "values": {
    "hide": true,
    "testableId": "myTestableId",
    "timeout": 20
  }
}
```

**Values**

Key          | Type    | Required | Supports Variable | Description
-------------|---------|----------|-------------------|-------------
`hide`       | boolean | No       | No                | Set to `true` to hide the widget and `false` to show it.
`testableId` | String  | Yes      | Yes               | Identifier for the `Testable`.
`timeout`    | number  | No       | No                | Number of seconds to wait for the `Testable` to appear on the Widget tree before failing.


---


### obscure_widget

**How it Works**

1. Attempts to locate the `Testable` on the widget tree using `testableId`; fails if it cannot be located by `timeout`.
2. Once located, sets the overlay color to `color`.

**Example**

```json
{
  "id": "obscure_widget",
  "image": "<optional_base_64_image>",
  "values": {
    "color": "#ff000000",
    "testableId": "myTestableId",
    "timeout": 20
  }
}
```

**Values**

Key          | Type    | Required | Supports Variable | Description
-------------|---------|----------|-------------------|-------------
`color`      | String  | No       | No                | Set to the `#aarrggbb` hex color to display as an overlay.
`testableId` | String  | Yes      | Yes               | Identifier for the `Testable`.
`timeout`    | number  | No       | No                | Number of seconds to wait for the `Testable` to appear on the Widget tree before failing.


