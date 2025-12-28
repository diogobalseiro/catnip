//
//  L10n.swift
//  catnip
//
//  Created by Diogo Balseiro on 27/12/2025.
//


import Foundation

enum L10n: String {

    case homeSearchPlaceholder
    case homeTabName
    case homeTitle

    case favoriteTabName

    var localized: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
    
    func localized(_ arguments: CVarArg...) -> String {
        let format = NSLocalizedString(self.rawValue, comment: "")
        return String(format: format, arguments: arguments)
    }
}
