//
//  AppState.swift
//  printers-company-crm
//
//  Created by George Stykalin on 17.10.2022.
//

import Foundation

struct AppState {
    static let databaseAddress = ProcessInfo.processInfo.environment["DATABASE_ADDRESS"]
    static let databasePort = ProcessInfo.processInfo.environment["DATABASE_PORT"]
    static let databaseName = ProcessInfo.processInfo.environment["DATABASE_NAME"]
    
    static var user: User? = nil
    
    static var userExists: Bool {
        if let _ = user {
            return true
        } else {
            return false
        }
    }
    
    static var userLoggedIn: Bool {
        do {
            let connection = try DatabaseAPI.getConnection(username: user?.username ?? "Unknown",
                                                           userPassword: user?.password ?? "Unknown")
            defer {
                connection.close()
            }
            return true
        } catch {
            print(error.localizedDescription)
        }
        return false
    }
}
