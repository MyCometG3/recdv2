### Appendix : Scripting

#### Recording with default folder, default name (date/time)

    tell application "recdv2"
      start recording
    end tell

    tell application "recdv2"
      stop recording
    end tell

#### Recording with specified file path

    tell application "recdv2"
      start recording in POSIX file "/Users/you/Desktop/a.mov"
    end tell

    tell application "recdv2"
      start recording in file "Monterey:Users:you:Desktop:b.mov"
    end tell

#### Recording with duration limit, and Auto Quit

    tell application "recdv2"
      start recording limit in seconds 60 with autoQuit
    end tell

#### Get/Set preview state for Audio/Video

    tell application "recdv2"
      set audioPreview to true
      get audioPreview
    end tell

    tell application "recdv2"
      set videoPreview to false
      get videoPreview
    end tell

#### Query current session and devices

    tell application "recdv2"
    	properties of currentSession
    end tell

    tell application "recdv2"
    	using muxed of currentSession
    end tell

    tell application "recdv2"
    	repeat with curItem in muxedDeviceInfos of currentSession
    		properties of curItem
    	end repeat
    	repeat with curItem in videoDeviceInfos of currentSession
    		properties of curItem
    	end repeat
    	repeat with curItem in audioDeviceInfos of currentSession
    		properties of curItem
    	end repeat
    end tell


#### Query current recording

    tell application "recdv2"
    	properties of currentRecording
    end tell

    tell application "recdv2"
      duration in seconds of currentRecording
      start date of currentRecording
      end date of currentRecording
      file of currentRecording
    end tell

Copyright © 2016-2023年 MyCometG3. All rights reserved.
