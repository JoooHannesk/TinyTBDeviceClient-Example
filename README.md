# TinyTBDeviceClient-Example
A reference implementation demonstrating how to use the [TinyTBDeviceClient](https://github.com/JoooHannesk/TinyTBDeviceClient) library to connect a device to a ThingsBoard server.
This project shows basic usage patterns and is intended as a starting point for your own IoT applications. It covers:
- Connect
- Disconect
- Push Telemetry
- Listen to RPCs (e.g. initiated through buttons and switches on a Dashboard)

## Dashboard representing the MQTT client device functionality
![thingsboard-sample-dashboart](https://github.com/JoooHannesk/TinyTBDeviceClient-Example/blob/main/Assets/)

## Requirements
- Computer running macOS (with Xcode or developer command-line tools) or Linux (with Swift), a Raspberry works as well
- Access to a ThingsBoard server instance with tenant admin authority

## Getting started
1. Create a new device in your ThingsBoard tenant. To work with the provided Dashboard file as is (without modifying the device name manually in every widget), name your device `SwiftMQTTDevice`. You don't need to set a specific device profile, just `default` will be fine.
2. When setting the device credentials, make sure to select `MQTT Basic` and provide the `client ID`, `username` and `password` (refer to screenshot below).
3. Clone this repo `git clone https://github.com/JoooHannesk/TinyTBDeviceClient-Example.git` it contains the whole SPM project. Open it in Xcode or navigate to the folder using Terminal.
4. Next, add your MQTT Basic credentials, these are stored in `credentials.json`. Navigate to (seen relative from this project top level) `Sources/TinyTBDeviceClient-Example/Credentials/` and rename `credentials.json.sample` to `credentials.json` and add your client device credentials.
5. Run this project (either using Xcode's play button / cmd+R) or via Terminal (inside project top level) using `swift run` command.
6. Check your ThingsBoard device list and make sure your device is connected (state = *active* and highlighted in *green*).
7. In your ThingsBoard, add a new dashboard by uploading the one provided in the `Assets` folder: `swiftmqttdevice.json`
8. Open the dashboard and press the buttons to see this sample project in action.

### MQTT-Basic client device credentials
![mqtt-basic-device-credentials](https://github.com/JoooHannesk/TinyTBDeviceClient-Example/blob/main/Assets/mqtt-device-credentials.png)
