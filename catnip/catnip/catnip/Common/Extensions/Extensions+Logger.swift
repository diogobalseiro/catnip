//
//  Extensions+Logger.swift
//  catnip
//
//  Created by Diogo Balseiro on 27/12/2025.
//

import OSLog

extension Logger {

    /// Shared logger
    nonisolated(unsafe) static var shared: Logger = {

        return Logger(subsystem: "Catnip", category: "main")
    }()
}
