# recdv2

recdv2 is a simple, audio/video capture application.

- __Requirement__: MacOS X 10.11 or later.
- __Capture Device__: Any AV devices compatible with AVCapture.framework,
including A/V mixed connection like DV.
- __Framework__ AVCaptureManager.framework. (Embedded)
- __Restriction__: Video-only or Audio-only recording are not supported.

#### Basic feature
- One click recording
- One click preview for Video/Audio
- Wide 16:9 or Legacy 4:3 screen video
- Multichannel audio
- Direct transcoding to H264+AAC.mov
- Direct transcoding to ProRes422+AAC.mov
- Instant de-interlace on transcoding (0.25-0.50-0.25)
- Temporal de-interlace (* Depends on decompressor)

#### Scripting feature
- Basic AppleScript support
- Automated file name creation based on date/time
- Recording limiter support
- AutoQuit support after recording is finished

#### Advanced feature
- Raw Video format recording
- YUV422 pixel format processing
- Non square pixel video support
- Strict pixel aspect ratio (e.g. 40:33 for NTSC-DV source)
- Clean aperture (e.g.720x480 <-> 704x480 for NTSC-DV source)
- ColorPrimaries/TransferFunctions/YCbCrMatrices ready
- LPCM Audio format recording support
- Preserve multichannel audio layout (* Depends on audio source)
- SMPTE timecode ready (* Depends on video source)

#### Development environment
- MacOS X 10.14.4 High Sierra
- Xcode 10.2
- Swift 5.0

#### License
- 3-clause BSD license

Copyright © 2016-2019年 MyCometG3. All rights reserved.
