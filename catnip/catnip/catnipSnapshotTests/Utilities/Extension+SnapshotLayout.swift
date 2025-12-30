//
//  Extension+SwiftUISnapshotLayout.swift
//  catnipSnapshotTests
//
//  Created by Diogo Balseiro on 29/12/2025.
//

import SnapshotTesting
import Foundation

extension SwiftUISnapshotLayout: @retroactive @unchecked Sendable {

    var shortName: String {
        switch self {
        case .device(let config):
            "w\(Int(config.size?.width ?? 0.0))h\(Int(config.size?.height ?? 0.0))"
        default:
            "unknown"
        }
    }
}
