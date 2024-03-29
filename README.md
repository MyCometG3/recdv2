## recdv2

recdv2 is a simple, audio/video capture application.

- __Requirement__: MacOS X 10.14.6 or later.
- __Capture Device__: Any AV devices compatible with AVCapture.framework,
including A/V mixed connection like DV.
- __UVC/UAC Devices__: Generall UVC/UAC devices are supported.
- __Restriction__: Only QuickTime movie (.mov) is supported.
- __Restriction__: Video-only or Audio-only source may not work.
- __Restriction__: Progressive/Frame based video is supported but Field based video is not supported.
- __Framework__ AVCaptureManager.framework. (Embedded)
- __Architecture__: Universal binary (x86_64 + arm64)

#### Basic feature
- One click recording
- One click preview for Video/Audio
- Wide 16:9 or Legacy 4:3 screen video
- Direct resizing video dimensions
- Direct transcoding to Prores422, H264 or HEVC video
- Direct transcoding to AAC/HE/HEv2 and Opus, AppleLossless and FLAC audio
- Instant de-interlace on transcoding (0.25-0.50-0.25)
- Fixed video frame rate capture (e.g. 60fps source => 12fps output)

#### Scripting feature
- Basic AppleScript support
- Automated file name creation based on date/time
- Recording duration limit support
- AutoQuit support after recording is finished

#### Advanced feature
- Capture in Device Native video format
- Custom video track timescale
- YUV422 pixel format processing (8bit/10bit)
- Temporal de-interlace (* Depends on decompressor support)
- Non square pixel video support
- Strict pixel aspect ratio (e.g. 40:33 for NTSC-DV source)
- Clean aperture/Overscan (e.g.720x480 <-> 704x480 for NTSC-DV source)
- ColorPrimaries/TransferFunctions/YCbCrMatrices ready
- LPCM Audio format recording support
- Preserve multichannel audio layout (* Depends on audio source)
- SMPTE timecode ready (* Depends on video source)

#### Development environment
- macOS 12.6.2 Monterey
- Xcode 14.2
- Swift 5.7.2

#### License
- MIT license

Copyright © 2016-2023年 MyCometG3. All rights reserved.
