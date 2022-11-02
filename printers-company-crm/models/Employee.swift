//
//  Employee.swift
//  printers-company-crm
//
//  Created by George Stykalin on 30.10.2022.
//

import Foundation

class Employee: Identifiable {
    let id = UUID()
    
    var name: String
    var surname: String
    var login: String
    var mobile: Int64
    var email: String
    var role: Role
    
    init(name: String, surname: String,
         login: String, mobile: Int64,
         email: String, role: Role) {
        self.name = name
        self.surname = surname
        self.login = login
        self.mobile = mobile
        self.email = email
        self.role = role
    }
}
