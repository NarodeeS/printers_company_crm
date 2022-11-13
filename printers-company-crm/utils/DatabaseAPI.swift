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
        configuration.socketTimeout = 3
        
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
        
        let statementText = "SELECT position_name "
                          + "FROM positions_classifier "
                          + "WHERE (position_code = (SELECT position_code "
                                                 + "FROM employees "
                                                 + "WHERE (employee_login = $1)));"
        
        let statement = try connection.prepareStatement(text: statementText)
        let cursor = try statement.execute(parameterValues: [username])
        if let row = try cursor.next()?.get() {
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
        return nil
    }
    
    static func executeStatement(statementText: String) throws {
        let connection = try getConnection(username: AppState.user?.username ?? "Unknown",
                                           userPassword: AppState.user?.password ?? "Unknown")
        defer {
            connection.close()
        }
        let statement = try connection.prepareStatement(text: statementText)
        defer {
            statement.close()
        }
        try statement.execute()
    }
    
    static func executeStatementWithResultId(statementText: String) throws -> Int64 {
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
        let row = try cursor.next()!.get()
        let columns = row.columns
        let id = Int64(try columns[0].int())
        return id
    }
    
    static func getClassifierValues(tableName: String) -> [Int: String] {
        var values = [Int: String]()
        let statementText = "SELECT * FROM \(tableName);"
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
                let code = try columns[0].int()
                let description = try columns[1].string()
                values[code] = description
            }
        } catch {
            print("Error: " + error.localizedDescription)
        }
        return values
    }
    
    static func getDataObjects<T: RowDerivable>(statementText: String, ofType: T.Type) -> [T.DataType] {
        var result = [T.DataType]()
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
                let obj = try ofType.createFromRow(row: row)
                result.append(obj)
            }
        } catch {
            print("Error: " + error.localizedDescription)
        }
        return result
    }
    
    static func getUserByLogin(login: String) throws -> Employee? {
        var employee: Employee? = nil
        
        let connection = try getConnection(username: AppState.user?.username ?? "Unknown",
                                           userPassword: AppState.user?.password ?? "Unknown")
        let statementText = "SELECT * FROM employees WHERE (employee_login = $1);"
        let statement = try connection.prepareStatement(text: statementText)
        let cursor = try statement.execute(parameterValues: [login])
        if let row = cursor.next() {
            employee = try Employee.createFromRow(row: row)
        }
        return employee
    }
    
    static func getEmployeeReport(startDate: Date, endDate: Date, employeeNumber: Int) throws -> [String: Int] {
        let postgresStartDate = startDate.postgresDate(in: TimeZone.autoupdatingCurrent)
        let postgresEndDate = endDate.postgresDate(in: TimeZone.autoupdatingCurrent)
        let statementText = "SELECT * FROM generate_report(\(employeeNumber),"
                                                   + " DATE '\(postgresStartDate)',"
                                                   + " DATE '\(postgresEndDate)');"
        var result = [String: Int]()
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
        let row = try cursor.next()!.get()
        let columns = row.columns
        result["All tasks"] = try columns[0].int()
        result["Tasks in time"] = try columns[1].int()
        result["Tasks not in time"] = try columns[2].int()
        result["Started, but expired tasks"] = try columns[3].int()
        result["Started, but not expired tasks"] = try columns[4].int()

        return result
    }
}
