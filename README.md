# TinyTBDeviceClient-Example
A reference implementation demonstrating how to use the [TinyTBDeviceClient](https://github.com/JoooHannesk/TinyTBDeviceClient) library to connect a device to a ThingsBoard server using MQTT.
This project shows basic usage patterns and is intended as a starting point for your own IoT applications. It covers:
- Connect
- Disconect
- Push Telemetry
- Listen to RPCs (e.g. initiated through buttons and switches on a Dashboard)

## Dashboard representing the MQTT client device functionality
The sample implementation acts as a client device visualized by this dashboard. It displays three different random numbers, each published by the client device.
Random number one and two can be updated by pushing the corresponding buttons, random number three gets updated automatically when activated through the switch.
![thingsboard-sample-dashboart](https://github.com/JoooHannesk/TinyTBDeviceClient-Example/blob/main/Assets/thingsboard-screenshot-dashboard.png)

## Requirements
- Computer running macOS (with Xcode or developer command-line tools) or Linux (with Swift), a Raspberry works as well
- Access to a ThingsBoard server instance with tenant admin authority

## Getting started
1. Create a new device in your ThingsBoard tenant. To work with the provided Dashboard file as is (without modifying the device name manually in every widget), name your device `SwiftMQTTDevice`. You don't need to set a specific device profile, just `default` will be fine.
2. When setting the device credentials, make sure to select `MQTT Basic` and provide the `client ID`, `username` and `password` (refer to screenshot below).
3. Clone this repo `git clone https://github.com/JoooHannesk/TinyTBDeviceClient-Example.git` it contains the whole SPM project. Open it in Xcode or navigate to the folder using Terminal.
4. Next, add your MQTT Basic credentials, these are stored in `credentials.json`. Navigate to (seen relative from this project top level) `Sources/TinyTBDeviceClient-Example/Credentials/` and rename `credentials.json.sample` to `credentials.json`. Then add your client device credentials.
5. Run this project (either using Xcode's play button / cmd+R) or via Terminal (inside project top level) using `swift run` command.
6. Check your ThingsBoard device list and make sure your device is connected (state = *active* and highlighted in *green*).
7. In your ThingsBoard, add a new dashboard by uploading the one provided in the `Assets` folder: `swiftmqttdevice.json`
8. Open the dashboard and press the buttons to see this sample project in action.
9. Sending a `SIGINT` or `SIGTERM` to the process will gracefully disconnect the client from your ThingsBoard server and terminate the app. (Means you can hit Ctrl+C to shutdown the process when running from your terminal.)

### MQTT-Basic client device credentials
![mqtt-basic-device-credentials](https://github.com/JoooHannesk/TinyTBDeviceClient-Example/blob/main/Assets/mqtt-device-credentials.png)

## SSL / TLS
In case you need to set up your own PKI for your MQTT or ThingsBoard server, look at the related post on my blog: [Building a Secure PKI for MQTT using OpenSSL](https://johanneskinzig.com/building-a-secure-pki-for-mqtt-using-openssl-root-ca-intermediate-ca-and-server-certificates.html)

## License
- Apache 2.0 License
- Copyright (c) 2026 Johannes Kinzig
- see LICENSE
