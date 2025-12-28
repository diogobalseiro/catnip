//
//  CatGateway+Environment.swift
//  catnip
//
//  Created by Diogo Balseiro on 27/12/2025.
//

import ComposableArchitecture
import Dependencies

private enum CatGatewayDependencyKey: DependencyKey, TestDependencyKey {

    public static let liveValue = Core.liveValue.managers.catGateway
    public static let stagingValue = Core.stagingValue.managers.catGateway
    public static let testValue = Core.testValue.managers.catGateway
}

extension DependencyValues {

    var catGateway: CatGatewayProtocol {

        get { self[CatGatewayDependencyKey.self] }
        set { self[CatGatewayDependencyKey.self] = newValue }
    }
}
