//
//  SocketConnector.swift
//  Maze
//
//  Created by Иван Абрамов on 12.11.2020.
//  Copyright © 2020 Иван Абрамов. All rights reserved.
//

import Foundation
import SocketIO

protocol SocketEventDelegate {
    func generated(map: String)
    func connected()
}

class SocketConnector {
    
    public static let shared = SocketConnector()
    var delegate: SocketEventDelegate?
    var manager: SocketManager
    var socket: SocketIOClient
    
    init() {
        
        manager = SocketManager(socketURL: URL(string: "http://ec2-18-219-156-28.us-east-2.compute.amazonaws.com:5555")!, config: [.reconnectAttempts(10), .forcePolling(true)])

        socket = manager.defaultSocket
        addHandlers()
    }
    
        func addHandlers() {
            socket.onAny {_ in 
            
//            print("\n\nGot event: \($0.event), with items: \(String(describing: $0.items))\n\n")
        }
        
        socket.on(clientEvent: .connect) {data, ack in
            
            self.delegate?.connected()
            
            guard let string = data.first as? String else {
                print("Cannot convert data")
                
                return
            }
            
            print("\nSocket connected \(string)  Ack: \(ack)\n")
        }
        
        socket.on(clientEvent: .disconnect) {data, ack in
            print("\nSocket disconnected\n")
        }
        
        socket.on(clientEvent: .error) {data, ack in
            print("\nSocket error\n")
        }

        socket.on(clientEvent: .statusChange) {data, ack in
            print("\nStatus change: \(data)\n")
        }
            
        socket.on("message") { (data, ack) in
            
            print("\n\nGot message: \(data) \(ack)")
            
//            guard let message = data.first as? String else {
//                print("Cannot convert data")
//
//                return
//            }
//
//            print("\n\nMessage contain: \(message)")
        }
            
        socket.on("map") { (data, ack) in
            
            guard let map = data.first as? String else {
                print("Cannot convert map")
                
                return
            }
            
            self.delegate?.generated(map: map)
        }
            
        
    }
    
    func connect(completion: @escaping () -> Void) {
         socket.connect(timeoutAfter: 100) {
             print("\n\nStatus: \(self.socket.status) \n\n")
             
             completion()
         }
         
         completion()
     }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func sendToServer(message: String) {
        socket.emit("message", message)
    }
    
    func requestMap(withWidth width: Int, andHeight length: Int, vortexProb: Double) {
        let dict = [
            "width": width,
            "length": length,
            "vortex_prob": vortexProb
            ] as [String : Any]
        
        print("Request map")
        
        socket.emit("generateMap", dict)
    }
}
