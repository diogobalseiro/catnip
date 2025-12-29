//
//  Reachability.swift
//  catnip
//
//  Created by Diogo Balseiro on 27/12/2025.
//

import Foundation
import Network
import Combine
import os

protocol ReachabilityProtocol {

    var isConnected: Bool { get  }
    var isConnectedPublisher: AnyPublisher<Bool, Never> { get }
}

final class Reachability: ReachabilityProtocol {

    var isConnected: Bool {

        isConnectedSubject.value
    }

    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        
        isConnectedSubject.eraseToAnyPublisher()
    }
    
    private let isConnectedSubject: CurrentValueSubject<Bool, Never>
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Reachability-\(UUID().uuidString)")

    init() {

         // Start with the current path status if available
         let currentStatus = monitor.currentPath.status == .satisfied
         self.isConnectedSubject = .init(currentStatus)
         
         monitor.pathUpdateHandler = { [weak self] path in

             DispatchQueue.main.async {

                 guard let self else { return }
                 let isConnected = path.status == .satisfied
                 self.isConnectedSubject.send(isConnected)
                 Logger.shared.debug("Connection is now \(isConnected ? "up" : "down")")
             }
         }

         monitor.start(queue: queue)
     }

     deinit {

         monitor.cancel()
     }
}


