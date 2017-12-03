//
//  NetworkSocket.swift
//  GDAXTicker
//
//  Created by Thomas Ricouard on 02/12/2017.
//  Copyright © 2017 Thomas Ricouard. All rights reserved.
//

import Foundation
import Starscream

class NetworkSocket {
    private let socket = WebSocket(url: URL(string: "wss://ws-feed.gdax.com")!)
    public var isConnected = false {
        didSet {
            onConnectionChange?(isConnected)
        }
    }
    private var dataToWrite: [Data] = []

    public var onTick: ((Tick) -> Void)?
    public var onConnectionChange: ((Bool) -> Void)?

    init() {
        socket.delegate = self
    }

    public func start() {
        socket.connect()
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
    func websocketDidConnect(socket: WebSocketClient) {
        isConnected = true
        if !dataToWrite.isEmpty {
            for data in dataToWrite {
                let json = String(data: data, encoding: .utf8)
                socket.write(string: json!)
            }
            dataToWrite.removeAll()
        }
    }

    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print(error ?? "Disconnected")
        isConnected = false
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
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

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        let string = String(data: data, encoding: .utf8)
        print(string ?? "No String")
    }
}
