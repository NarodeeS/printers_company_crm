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
                        if let userRole = try DatabaseAPI.getUserGroupRole(username: username, password: userPassword) {
                            print(username + " " + userPassword)
                            AppState.user = User(role: userRole, username: username, password: userPassword)
                            try AppState.user!.save()
                            dismiss()
                        } else {
                            alertMessage = "Something went wrong..."
                            showingConnectionError = true
                        }
                    } catch PostgresError.socketError {
                        alertMessage = "The connection could not be established. Verify the validity of the entered data"
                        showingConnectionError = true
                    } catch {
                        alertMessage = error.localizedDescription
                        showingConnectionError = true
                    }
                }
            }
            .navigationTitle("Authentication")
            .alert("Error", isPresented: $showingConnectionError) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
            .interactiveDismissDisabled()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
