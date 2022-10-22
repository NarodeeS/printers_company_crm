//
//  LoginView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 17.10.2022.
//

import SwiftUI
import PostgresClientKit

struct LoginView: View {
    @State private var username = ""
    @State private var userPassword = ""
    @State private var showingConnectionError = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Enter your username", text: $username)
                    .textInputAutocapitalization(.never)
                SecureField("Enter your password", text: $userPassword)
                    .textInputAutocapitalization(.never)
                Button("Login") {
                    do {
                        if let connection = User.getConnection(username: username, userPassword: userPassword) {
                            if let userRole = try getUserGroupRole(connection: connection, username: username) {
                                AppState.user = User(role: userRole, username: username, password: userPassword, connection: connection)
                                try AppState.user!.save()
                                dismiss()
                            } else {
                                alertMessage = "Something went wrong..."
                                showingConnectionError = true
                            }
                        }
                    } catch PostgresError.socketError {
                        alertMessage = "The connection could not be established. Verify the validity of the entered data"
                        showingConnectionError = true
                    } catch {
                        alertMessage = "There was an error"
                        showingConnectionError = true
                    }
                }
            }
            .navigationTitle("Authentication")
            .alert("Error", isPresented: $showingConnectionError) {
                Button("OK") {}
            } message: {
                Text("Problems with connection. Check the input and try again")
            }
            .interactiveDismissDisabled()
        }
    }
    
    // Получение групповой роли пользователя при подключении
    func getUserGroupRole(connection: Connection, username: String) throws -> Role? {
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
                
                statementText = "SELECT rolname FROM pg_roles WHERE oid=$1"
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
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
