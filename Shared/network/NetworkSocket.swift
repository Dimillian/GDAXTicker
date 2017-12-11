//
//  NetworkSocket.swift
//  GDAXTicker
//
//  Created by Thomas Ricouard on 02/12/2017.
//  Copyright © 2017 Thomas Ricouard. All rights reserved.
//

import Foundation
import Starscream

open class NetworkSocket {

    public var isConnected = false {
        didSet {
            onConnectionChange?(isConnected)
        }
    }
    private var dataToWrite: [Data] = []
    private var socket: WebSocket!
    public var onTick: ((Tick) -> Void)?
    public var onConnectionChange: ((Bool) -> Void)?
    public var onDisconnect: (() -> Void)?

    public init() {
        socket = WebSocket(request: URLRequest(url: URL(string: "")!))
    }

    public func start() {
        
    }

    public func subscribe(subscription: Subscribe) {
        if let data = encode(object: subscription) {
            if isConnected {
                let json = String(data: data, encoding: .utf8)
                socket.write(string: json!)
            } else {
                dataToWrite.append(data)
            }
        }
    }

    public func stop() {
        socket.onDisconnect = {_ in
            self.onDisconnect?()
        }
        socket.disconnect()
    }
    
}

extension NetworkSocket {
    public func encode<T: Codable>(object: T) -> Data? {
        let jsonEncoder = JSONEncoder()
        do {
            let data = try jsonEncoder.encode(object)
            return data
        } catch let error {
            print("JSON Encoding error: \(error.localizedDescription)")
        }
        return nil
    }
}

extension NetworkSocket: WebSocketDelegate {
    public func websocketDidConnect(socket: WebSocketClient) {
        isConnected = true
        if !dataToWrite.isEmpty {
            for data in dataToWrite {
                let json = String(data: data, encoding: .utf8)
                socket.write(string: json!)
            }
            dataToWrite.removeAll()
        }
    }

    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print(error ?? "Disconnected")
        isConnected = false
    }

    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if let data = text.data(using: .utf8) {
            let decoder = JSONDecoder()
            do {
                let tick = try decoder.decode(Tick.self, from: data)
                onTick?(tick)
            } catch let error {
                print("Error decoding JSON: \(error)")
            }
        }
    }

    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        let string = String(data: data, encoding: .utf8)
        print(string ?? "No String")
    }
}
