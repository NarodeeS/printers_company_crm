//
//  Employee.swift
//  printers-company-crm
//
//  Created by George Stykalin on 30.10.2022.
//

import Foundation
import PostgresClientKit

class Employee: Identifiable, RowDerivable {
    typealias DataType = Employee
    
    static let getAllStatementText = "SELECT * FROM employees;"
    
    let id: Int
    var name: String
    var surname: String
    var login: String
    var mobile: Int64
    var email: String
    var role: Role
    
    init(number: Int, name: String, surname: String,
         login: String, mobile: Int64,
         email: String, role: Role) {
        self.id = number
        self.name = name
        self.surname = surname
        self.login = login
        self.mobile = mobile
        self.email = email
        self.role = role
    }
    
    static func getCreateStatementText(name: String, surname: String,
                                       login: String, password: String,
                                       mobile: Int64, email: String,
                                       positionCode: Int) -> String {
        return "CALL create_user('\(name)', '\(surname)', '\(login)', '\(password)', \(mobile)::BIGINT, '\(email)', \(positionCode)::SMALLINT);"
    }
    
    static func createGetByIdStatement(id: Int) -> String {
        return "SELECT * FROM employees WHERE (employee_number = \(id));"
    }
    
    static func createFromRow(row: Result<Row, any Error>) throws -> Employee {
        let columns = try row.get().columns
        let number = try columns[0].int()
        let name = try columns[1].string()
        let surname = try columns[2].string()
        let login = try columns[3].string()
        let mobile = Int64(try columns[4].int())
        let email = try columns[5].string()
        let positionCode = try columns[6].int()
        var role = Role.admin
        switch positionCode {
        case 1:
            role = Role.manager
        case 2:
            role = Role.worker
        default:
            role = Role.admin
        }
        return Employee(number: number, name: name,
                        surname: surname, login: login,
                        mobile: mobile, email: email,
                        role: role)
    }
}
