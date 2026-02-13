
//
//  TinyTBDeviceClient_Example.swift
//  TinyTBDeviceClient_Example
//
//  Created by Johannes Kinzig on 06.02.26.
//


import TinyTBDeviceClient
import NIO
import Foundation
import Logging


// MARK: - MQTT Client related
var client: TinyTBDeviceClient
let eventLoopGroup: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let eventLoopGroupNioProvider: NIOEventLoopGroupProvider = .shared(eventLoopGroup)
let logger = Logger(label: "TinyTBDeviceClient")
let rpcTopics: [String] = ["v1/devices/me/rpc/request/+"]
let telemetryTopic: String = "v1/devices/me/telemetry"

let clientCredentials: MQTTClientCredentials = ConfigLoader(searchPath: "Credentials", logger: logger).loadClientCredentialsFromFile(fileName: "credentials.json")!

do {
    client = try TinyTBDeviceClient(
        host: clientCredentials.host,
        port: clientCredentials.port,
        clientId: clientCredentials.clientId,
        caCertPath: clientCredentials.caCertPath,
        username: clientCredentials.username,
        password: clientCredentials.password,
        eventLoopGroupProvider: eventLoopGroupNioProvider,
        logger: logger
    )
} catch {
    fatalError("Unable to initialize client: \(error)")
}

RPCMessageProcessor.eventLoop = eventLoopGroup.next()
RPCMessageProcessor.telemetryTopic = telemetryTopic
RPCMessageProcessor.mqttClient = client

client.registerMessageListener(named: "RPC Listener") { message, topic in
    print("Received message with payload \(message) for topic \(topic)")
    RPCMessageProcessor.process(message: message, topic: topic)

}

client.connect(
    onSuccess: {
        print("✅ Connected (CA pinned)")
        client.subscribe(
            to: rpcTopics,
            onSuccess: { topic, subAck in
                print("✅ Subscribed to \(topic) with \(subAck)")
            },
            onError: { error in
                print("❌ Subscribe failed:", error)
            }
        )
    },
    onError: { error in
        print("❌ Connection failed:", error)
    }
)


// MARK: POSIX Signals related
let sigintSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
let sigtermSource = DispatchSource.makeSignalSource(signal: SIGTERM, queue: .main)

sigintSource.setEventHandler { handle(signal: SIGINT) }
sigtermSource.setEventHandler { handle(signal: SIGTERM) }

sigintSource.resume()
sigtermSource.resume()

// MARK: Signal handling

/// Handle received signal
///
/// In this simplified case, disconnect and shut down
func handle(signal: Int32) {
    print("Received signal \(signal).")

    sigintSource.cancel()
    sigtermSource.cancel()

    do {
        client.disconnect()
        try eventLoopGroup.syncShutdownGracefully()
        print("EventLoopGroup shut down.")
    } catch {
        print("Shutdown error: \(error)")
    }
    exit(0)
}

print("PID: \(getpid())")
dispatchMain()

