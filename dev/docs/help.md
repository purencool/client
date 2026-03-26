### Add Keychain Sharing Entitlement when installing Mac dev environment.
#### Error. 
Code: -34018 is a macOS/iOS security error, specifically from the Keychain APIs.
```
Unhandled Exception: PlatformException(Unexpected security result code, Code: -34018, Message: A required entitlement isn't present., -34018, null)
```
#### Solution.
- Open macos/Runner.xcworkspace in the developmennt environment.
- Select your project in the left sidebar.
- Select the Runner target under "Targets".
- Go to the "Signing & Capabilities" tab.
- Click "+ Capability" and add "Keychain Sharing".
- Save and rebuild your app.

#### Error
```
[ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: PlatformException(ENTITLEMENT_NOT_FOUND, Either the Read-Only or Read-Write entitlement is required for this action., null, null)
```
#### Solution
- Open Your Project in Xcode open macos/Runner.xcworkspace
- Select your project in the left sidebar.
- Select the Runner target under "Targets".
- Go to the "Signing & Capabilities" tab.
- Find references to to the file system in the main page and change them to read and write.
```

