//
//  PaginationMetadata.swift
//  catnip
//
//  Created by Diogo Balseiro on 27/12/2025.
//

import Foundation
import SwiftData

@Model
final class PaginationMetadataManagedModel {

    var page: Int
    var limit: Int

    init(page: Int,
         limit: Int) {

        self.page = page
        self.limit = limit
    }
}

extension PaginationMetadataManagedModel: PaginationProtocol {}
