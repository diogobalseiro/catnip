//
//  Reachabbility+Environment.swift
//  catnip
//
//  Created by Diogo Balseiro on 27/12/2025.
//

import ComposableArchitecture
import Dependencies

private enum ReachabilityDependencyKey: DependencyKey, TestDependencyKey {

    static let liveValue: any ReachabilityProtocol = Core.liveValue.managers.reachability
    static let stagingValue: any ReachabilityProtocol = Core.stagingValue.managers.reachability
    static let testValue: any ReachabilityProtocol = Core.testValue.managers.reachability
}

extension DependencyValues {

    var reachability: any ReachabilityProtocol {

        get { self[ReachabilityDependencyKey.self] }
        set { self[ReachabilityDependencyKey.self] = newValue }
    }
}
