//
//  Core+Environment.swift
//  catnip
//
//  Created by Diogo Balseiro on 27/12/2025.
//

import ComposableArchitecture
import Dependencies

extension Core: DependencyKey, TestDependencyKey {

    public static let liveValue = Core(environment: .live)
    public static let stagingValue = Core(environment: .staging(delay: .milliseconds(200)))
    public static let testValue = Core(environment: .staging(delay: .milliseconds(200)))
}

extension DependencyValues {

    var core: Core {

        get { self[Core.self] }
        set { self[Core.self] = newValue }
    }
}

extension Core.Environment: DependencyKey, TestDependencyKey {

    public static let liveValue = Core.liveValue.environment
    public static let stagingValue = Core.stagingValue.environment
    public static let testValue = Core.testValue.environment
}

extension DependencyValues {

    var environment: Core.Environment {

        get { self[Core.Environment.self] }
        set { self[Core.Environment.self] = newValue }
    }
}
