//
//  User.swift
//  printers-company-crm
//
//  Created by George Stykalin on 17.10.2022.
//

import Foundation
import PostgresClientKit

enum Role: String, Codable {
    case admin = "Administator"
    case worker = "Worker"
    case manager = "Manager"
}

final class User: Codable {
    var role: Role
    var username: String
    var password: String
    var connection: Connection? = nil
    
    enum CodingKeys: CodingKey {
        case role, username, password
    }
    
    init(role: Role, username: String, password: String, connection: Connection) {
        self.role = role
        self.username = username
        self.password = password
        self.connection = connection
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.role = try container.decode(Role.self, forKey: .role)
        self.username = try container.decode(String.self, forKey: .username)
        self.password = try container.decode(String.self, forKey: .password)
        
        connection = Self.getConnection(username: username, userPassword: password)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.role, forKey: .role)
        try container.encode(self.username, forKey: .username)
        try container.encode(self.password, forKey: .password)
    }
    
    func save() throws {
        let encoder = JSONEncoder()
        let encodedUser = try encoder.encode(self)
        UserDefaults.standard.setValue(encodedUser, forKey: "user")
    }
    
    static func getConnection(username: String, userPassword: String) -> Connection? {
        var configuration = PostgresClientKit.ConnectionConfiguration()
        configuration.host = AppState.databaseAddress!
        configuration.port = Int(AppState.databasePort!)!
        configuration.database = AppState.databaseName!
        configuration.user = username
        configuration.credential = .scramSHA256(password: userPassword)
        
        let connection = try? PostgresClientKit.Connection(configuration: configuration)
        return connection
    }
    
    
}
