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

final class User: Codable, ObservableObject {
    @Published var role: Role
    @Published var username: String
    @Published var password: String
    
    enum CodingKeys: CodingKey {
        case role, username, password
    }
    
    init(role: Role, username: String, password: String) {
        self.role = role
        self.username = username
        self.password = password
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.role = try container.decode(Role.self, forKey: .role)
        self.username = try container.decode(String.self, forKey: .username)
        self.password = try container.decode(String.self, forKey: .password)
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
    
    func delete() {
        UserDefaults.standard.removeObject(forKey: "user")
    }
}
