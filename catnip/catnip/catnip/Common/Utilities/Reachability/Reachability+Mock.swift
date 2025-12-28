//
//  Reachability+Mock.swift
//  catnip
//
//  Created by Diogo Balseiro on 27/12/2025.
//

import Combine

extension Reachability {

    final class Mock: ReachabilityProtocol {
        
        let subject = CurrentValueSubject<Bool, Never>(true)
        var isConnected: Bool { subject.value }
        var isConnectedPublisher: AnyPublisher<Bool, Never> { subject.eraseToAnyPublisher() }
    }
}
