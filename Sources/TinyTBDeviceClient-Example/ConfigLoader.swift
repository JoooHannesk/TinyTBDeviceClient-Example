//
//  ConfigLoader.swift
//  TinyTBDeviceClient-Example
//
//  Created by Johannes Kinzig on 16.09.25.
//

import Foundation
import Logging

struct MQTTClientCredentials: Codable {
    let host: String
    let port: Int
    let caCertPath: String
    let clientId: String
    let username: String
    let password: String
}


struct ConfigLoader {

    let searchPath: String
    let logger: Logger?

    /**
     Load MQTT client credentials from file
     - Parameter fileName: file name to load (including file type extension, e.g. config.json)
     - Returns: `MQTTClientCredentials` object
     - Note: Returns nil in case data was not able to be loaded from file
     */
    func loadClientCredentialsFromFile(fileName: String) -> MQTTClientCredentials? {
        let decoder = JSONDecoder()
        if let textData = loadTextFromFile(fileName: fileName) {
            let userCredentials = try? decoder.decode(MQTTClientCredentials.self, from: textData)
            return userCredentials
        }
        self.logger?.error("Error loading config from file: \(fileName).json")
        return nil
    }
    
    // MARK: Private methods
    
    /**
     Return path to requested file
     - Parameter fileName: file name to load (including file type extension, e.g. config.json)
     - Returns: URL to file
     */
    private func getPathToResource(fileName: String) -> URL {
        let fileName = fileName
        let urlToThisFile = URL(fileURLWithPath: #file, isDirectory: false).deletingLastPathComponent()
        return urlToThisFile.appendingPathComponent(searchPath).appendingPathComponent(fileName)
    }
    
    /**
     Load text from file
     - Parameter fileName: file name to load (including file type extension, e.g. config.json)
     - Returns: text as Data?
     - Note: Returns nil in case data was not able to be loaded from file
     */
    private func loadTextFromFile(fileName: String) -> Data? {
        let fileUrl = getPathToResource(fileName: fileName)
        // print("File Path: \(fileUrl)")
        if let jsonData = try? Data(contentsOf: fileUrl) {
            // print("Mock data: \(String(decoding: jsonData, as: UTF8.self))")
            return jsonData
            }
        else {
            self.logger?.error("Error loading file: \(fileName)")
            return nil
        }
    }
}
