//
//  DatabaseAPI.swift
//  printers-company-crm
//
//  Created by George Stykalin on 30.10.2022.
//

import Foundation
import PostgresClientKit

class DatabaseAPI {
    static func getConnection(username: String, userPassword: String) throws -> Connection {
        var configuration = PostgresClientKit.ConnectionConfiguration()
        configuration.host = AppState.databaseAddress!
        configuration.port = Int(AppState.databasePort!)!
        configuration.database = AppState.databaseName!
        configuration.user = username
        configuration.credential = .scramSHA256(password: userPassword)
        
        let connection = try PostgresClientKit.Connection(configuration: configuration)
        return connection
    }
    
    static func getUserGroupRole(username: String, password: String) throws -> Role? {
        let connection = try getConnection(username: username, userPassword: password)
        defer {
            connection.close()
        }
        if username == ProcessInfo.processInfo.environment["ADMIN_USERNAME"] {
            return Role.admin
        }
        
        var statementText = "SELECT oid FROM pg_roles WHERE rolname=$1;"
        var statement = try connection.prepareStatement(text: statementText)
        defer {
            statement.close()
        }
        var cursor = try statement.execute(parameterValues: [username])
        defer {
            cursor.close()
        }
        if let row = try? cursor.next()?.get() {
            let columns = row.columns
            let userOid = try columns[0].int()
            
            statementText = "SELECT roleid FROM pg_auth_members WHERE member=$1;"
            statement = try connection.prepareStatement(text: statementText)
            cursor = try statement.execute(parameterValues: [userOid])
            if let row = try? cursor.next()?.get() {
                let columns = row.columns
                let roleId = try columns[0].int()
                
                statementText = "SELECT rolname FROM pg_roles WHERE oid=$1;"
                statement = try connection.prepareStatement(text: statementText)
                cursor = try statement.execute(parameterValues: [roleId])
                if let row = try? cursor.next()?.get() {
                    let columns = row.columns
                    let rolename = try columns[0].string()
                    
                    switch rolename {
                    case "manager":
                        return Role.manager
                    case "worker":
                        return Role.worker
                    default:
                        return nil
                    }
                }
            }
        }
        return nil
    }
    
    static func getPositionCodes() -> [Int: String] {
        var positionsCodes = [Int: String]()
        let statementText = "SELECT * FROM positions_classifier;"
        do {
            let connection = try getConnection(username: AppState.user?.username ?? "Unknown",
                                               userPassword: AppState.user?.password ?? "Unknown")
            defer {
                connection.close()
            }
            let statement = try connection.prepareStatement(text: statementText)
            defer {
                statement.close()
            }
            let cursor = try statement.execute()
            defer {
                cursor.close()
            }
            for row in cursor {
                let columns = try row.get().columns
                let positionCode = try columns[0].int()
                let positionName = try columns[1].string()
                positionsCodes[positionCode] = positionName
            }
        } catch {
            print("Error: " + error.localizedDescription)
        }
        return positionsCodes
    }
    
    static func createUser(name: String, surname: String,
                           login: String, password: String, mobilePhone: Int64,
                           email: String, positionCode: Int) throws {
        let connection = try getConnection(username: AppState.user?.username ?? "Unknown",
                                           userPassword: AppState.user?.password ?? "Unknown")
        defer {
            connection.close()
        }
        let statementText = "CALL create_user('\(name)', '\(surname)', '\(login)', '\(password)', \(mobilePhone)::BIGINT, '\(email)', \(positionCode)::SMALLINT);"
        let statement = try connection.prepareStatement(text: statementText)
        defer {
            statement.close()
        }
        try statement.execute()
    }
    
    static func getUsers() -> [Employee]{
        let statementText = "SELECT * FROM employees;"
        var result = [Employee]()
        do {
            let connection = try getConnection(username: AppState.user?.username ?? "Unknown",
                                               userPassword: AppState.user?.password ?? "Unknown")
            defer {
                connection.close()
            }
            let statement = try connection.prepareStatement(text: statementText)
            defer{
                statement.close()
            }
            let cursor = try statement.execute()
            defer {
                cursor.close()
            }
            for row in cursor {
                let columns = try row.get().columns
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
                result.append(Employee(name: name, surname: surname,
                                       login: login, mobile: mobile,
                                       email: email, role: role))
            }
        } catch {
            print("Error: " + error.localizedDescription)
        }
        return result
    }
}
