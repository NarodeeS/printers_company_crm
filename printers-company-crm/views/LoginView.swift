//
//  LoginView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 17.10.2022.
//

import SwiftUI
import PostgresClientKit

struct LoginView: View {
    @StateObject private var viewModel = ViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Enter your username", text: $viewModel.username)
                    .textInputAutocapitalization(.never)
                SecureField("Enter your password", text: $viewModel.userPassword)
                    .textInputAutocapitalization(.never)
                Button("Login") {
                    do {
                        if let userRole = try DatabaseAPI.getUserGroupRole(username: viewModel.username,
                                                                           password: viewModel.userPassword) {
                            AppState.user = User(role: userRole,
                                                 username: viewModel.username,
                                                 password: viewModel.userPassword)
                            try AppState.user!.save()
                            dismiss()
                        } else {
                            viewModel.alertMessage = "Something went wrong..."
                            viewModel.showingConnectionError = true
                        }
                    } catch PostgresError.socketError {
                        viewModel.alertMessage = "The connection could not be established. Verify the validity of the entered data"
                        viewModel.showingConnectionError = true
                    } catch {
                        viewModel.alertMessage = error.localizedDescription
                        viewModel.showingConnectionError = true
                    }
                }
            }
            .navigationTitle("Authentication")
            .alert("Error", isPresented: $viewModel.showingConnectionError) {
                Button("OK") {}
            } message: {
                Text(viewModel.alertMessage)
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
