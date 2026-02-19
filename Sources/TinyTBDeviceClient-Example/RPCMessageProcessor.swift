//
//  RPCMessageProcessor.swift
//  MQTTTBClientImpl
//
//  Created by Johannes Kinzig on 04.02.26.
//

import TinyTBDeviceClient
import Foundation
import NIO


struct RPCCommand: Codable {
    let method: String
    let params: [String: Int]?
}

/// Simple message processor to evaluate RPC messages received from the IoT Cloud
enum RPCMessageProcessor {

    static var eventLoop: EventLoop?
    static var mqttClient: TinyTBDeviceClient?
    static var telemetryTopic: String?
    static var scheduledTelemetryPushTask: RepeatedTask?

    /// Processes an incoming RPC message from the IoT Cloud.
    ///
    /// The function expects a UTF-8 encoded JSON string that decodes into `RPCCommand`.
    /// It attempts to parse the message and dispatches handling based on the
    /// `method` and `params` contained in the payload. Currently supports the
    /// `getRandom` method with a `number` parameter.
    ///
    /// - Parameters:
    ///    - message: A JSON string representing the RPC command. Example: `{"method":"getRandom","params":{"number":1}}`
    ///    - topic: Topic the message was published under
    ///
    /// - Note: On unknown methods/parameters or failures, the function logs details
    ///   to the console using `print` and does not throw.
    static func process(message: String, topic: String? = nil) {
        do {
            // Parse the JSON string into your command model
            guard let data = message.data(using: .utf8) else {
                print("Failed to convert message string to data")
                return
            }
            let rpcCommand = try JSONDecoder().decode(RPCCommand.self, from: data)

            switch rpcCommand.method {

            // Method: getRandom
            case "getRandom":
                guard let number = rpcCommand.params?["number"] else {
                    print("⚠️ Missing 'number' parameter for method \(rpcCommand.method)")
                    return
                }
                switch number {
                case 1:
                    self.publishNo1Telemetry()
                case 2:
                    self.publishNo2Telemetry()
                default:
                    print("⚠️ Unsupported 'number' value: \(number)")
                }

            // Method: runScheduler
            case "runScheduler":
                guard let enable = rpcCommand.params?["enable"] else {
                    print("⚠️ Missing 'number' parameter for method \(rpcCommand.method)")
                    return
                }
                switch enable {
                case 0:
                    Self.stopScheduledTelemetryPushTask()
                case 1:
                    Self.startScheduledTelemetryPushTask()
                default:
                    print("⚠️ Unsupported 'enable' value: \(enable)")
                }

            // Method: schedulerIsRunning
            case "schedulerIsRunning":
                guard let topic = topic else { return }
                Self.mqttClient?.respondToRPCRequest(rpcRequestTopic: topic, responseMessage: "\(scheduledTelemetryPushTaskIsRunning)")

            default:
                    print("Unknown method: \(rpcCommand.method)")
            }
        } catch {
            print("Failed to decode RPC command: \(error)")
        }
    }


    // MARK: - Private Functions

    /// Publish telemetry: random number 1
    static private func publishNo1Telemetry() {
        guard let telemetryTopic = self.telemetryTopic else {
            return
        }
        publishTelemetry(message: #"{"random1": \#(getRandomNumber(min: 0, max: 500))}"#, topic: telemetryTopic)
    }

    /// Publish telemetry: random number 2
    static private func publishNo2Telemetry() {
        guard let telemetryTopic = self.telemetryTopic else {
            return
        }
        publishTelemetry(message: #"{"random2": \#(getRandomNumber(min: 501, max: 999))}"#, topic: telemetryTopic)
    }

    /// Publish telemetry: random number 3
    static private func publishNo3Telemetry() {
        guard let telemetryTopic = self.telemetryTopic else {
            return
        }
        publishTelemetry(message: #"{"random3": \#(getRandomNumber(min: 1000, max: 1500))}"#, topic: telemetryTopic)
    }

    /// Publishes telemetry data to the specified MQTT topic.
    ///
    /// This method uses the configured MQTT client to publish a message
    /// to the given topic. It handles both success and error cases,
    /// logging appropriate messages to the console.
    ///
    /// - Parameters:
    ///   - message: The JSON string containing telemetry data to publish
    ///   - topic: The MQTT topic to which the message should be published
    ///
    /// - Note: This method relies on a shared `mqttClient` instance that must
    ///   be configured before calling this function. If the client is not set,
    ///   no message will be published.
    static private func publishTelemetry(message: String, topic: String) {
        Self.mqttClient?.publish(
            message: message,
            to: topic,
            onSuccess: { print("📤 Telemetry published: \(message)") },
            onError: { error in
                print("❌ Telemetry publish failed: \(error)")
            }
        )
    }


    /// Return a random integer between a minimum and a maximum boundary
    /// - Parameters:
    ///   - min: Minimum boundary
    ///   - max: Maximum boundary
    /// - Returns: Random number between boundaries
    static private func getRandomNumber(min: Int = 0, max: Int = 1000) -> Int {
        return Int.random(in: min...max)
    }


    /// Starts a scheduled telemetry push task that publishes random number
    /// telemetry data at regular intervals.
    ///
    /// This function creates a repeating task that publishes telemetry
    /// data containing random number 3 to the configured MQTT topic.
    /// The task runs at 1-second intervals and can be stopped using
    /// `stopScheduledTelemetryPushTask()`.
    ///
    /// The function cancels any existing scheduled task before creating
    /// a new one to prevent multiple simultaneous tasks from running.
    ///
    /// See also: `stopScheduledTelemetryPushTask()`, `scheduledTelemetryPushTaskIsRunning`
    ///
    /// - Note: This function requires `eventLoop` and `mqttClient` to be configured
    ///   before it can function properly. If either is not set, the task will not be created.
    ///
    /// - Important: The task publishes data using `publishNo3Telemetry()` which
    ///   generates telemetry with a random number between 1000 and 1500.
    private static func startScheduledTelemetryPushTask() {
        // Cancel any existing task first
        Self.stopScheduledTelemetryPushTask()

        // Schedule the repeating task - using the correct syntax for Swift on Linux
        Self.scheduledTelemetryPushTask = Self.eventLoop?.scheduleRepeatedTask(initialDelay: .seconds(0), delay: .seconds(1)) { _ in
            if let isConnected = mqttClient?.isConnected {
                if isConnected {
                    Self.publishNo3Telemetry()
                } else {
                    Self.stopScheduledTelemetryPushTask()
                    print("⚠️ Client lost connection, stopping scheduled telemetry push task.")
                }
            }
        }
    }

    /// Stops any currently running scheduled telemetry push task.
    ///
    /// This function cancels the existing repeating task that publishes random number
    /// telemetry data at regular intervals. If no task is currently running, this function
    /// has no effect.
    ///
    /// The function clears the `scheduledTelemetryPushTask` property, effectively stopping
    /// any further executions of the scheduled task.
    ///
    /// See also: `startScheduledTelemetryPushTask()`, `scheduledTelemetryPushTaskIsRunning`
    ///
    /// - Note: This function is intended for internal use only and should not be called
    ///   directly from outside this module.
    private static func stopScheduledTelemetryPushTask() {
        Self.scheduledTelemetryPushTask?.cancel()
        Self.scheduledTelemetryPushTask = nil
    }

    /// Indicates whether the scheduled telemetry push task is currently running.
    ///
    /// This computed property returns 1 if a scheduled telemetry push task
    /// is currently active, or 0 if no such task is running.
    ///
    /// The value is determined by checking whether the `scheduledTelemetryPushTask`
    /// property contains a valid task reference.
    ///
    /// - Returns: 1 if the scheduler is running, 0 otherwise
    ///
    /// Example:
    /// ```swift
    /// // Check if scheduler is running
    /// let running = "\(scheduledTelemetryPushTaskIsRunning)"
    /// ```
    ///
    /// See also: `startScheduledTelemetryPushTask()`, `stopScheduledTelemetryPushTask()`
    static var scheduledTelemetryPushTaskIsRunning: Int {
        return (Self.scheduledTelemetryPushTask != nil) ? 1 : 0
    }
}

