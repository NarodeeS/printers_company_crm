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
    @ObservedObject var mainViewViewModel: MainView.ViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Enter your username", text: $viewModel.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                SecureField("Enter your password", text: $viewModel.userPassword)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                Button("Login") {
                    do {
                        if let userGroup = try DatabaseAPI.getUserGroupRole(username: viewModel.username,
                                                                            password: viewModel.userPassword) {
                            AppState.user = User(role: userGroup,
                                                 username: viewModel.username,
                                                 password: viewModel.userPassword)
                            try AppState.user!.save()
                            mainViewViewModel.tabSelection = 2
                        }
                        dismiss()
                    } catch PostgresError.socketError {
                        viewModel.alertMessage = "The connection could not be established. Contact developers"
                        viewModel.showingConnectionError = true
                    } catch {
                        viewModel.alertMessage = "Wrong credentials"
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
