//
//  FeatureTests.swift
//  catnip
//
//  Created by Diogo Balseiro on 28/12/2025.
//

import Foundation
import Testing
import CatsKitDomain
import CatsKitDomainStaging
import ComposableArchitecture
@testable import catnip

@MainActor
@Suite("Feature")
struct FeatureTests {
    
    static func makeTestCore(insert breeds: [CatBreed] = []) async throws -> Core {
        
        let core = Core(environment: .staging(delay: .milliseconds(200)))
        
        if breeds.isEmpty == false,
           let catGateway = core.managers.catGateway as? CatGateway {
            
            try catGateway.insert(breeds)
        }
        
        return core
    }
    
    final class OffsetCounter: @unchecked Sendable {
        
        let lock = NSLock()
        var currentOffset = 0.0
        
        func nextOffset() -> TimeInterval {
            lock.lock()
            defer { lock.unlock() }
            
            let offset = currentOffset
            currentOffset += 1.0
            return offset
        }
    }
}
