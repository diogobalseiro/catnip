//
//  Extension+Alignment.swift
//  catnipSnapshotTests
//
//  Created by Diogo Balseiro on 29/12/2025.
//

import SwiftUI

extension Alignment {

    var shortName: String {

        switch self {

        case .topLeading: return "topLeading"
        case .top: return "top"
        case .topTrailing: return "topTrailing"
        case .leading: return "leading"
        case .center: return "center"
        case .trailing: return "trailing"
        case .bottomLeading: return "bottomLeading"
        case .bottom: return "bottom"
        case .bottomTrailing: return "bottomTrailing"
            
        default: return "custom"
        }
    }
}
