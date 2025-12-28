//
//  Extensions+URL.swift
//  catnip
//
//  Created by Diogo Balseiro on 27/12/2025.
//

import Foundation

extension URL {
    
    /// Convenience initializer
    /// - Parameter possibleString: An optional string
    init?(possibleString: String?) {

        guard let possibleString else {

            return nil
        }

        self.init(string: possibleString)
    }
}
