//
//  LoginView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 02.11.2022.
//

import Foundation

extension LoginView {
    @MainActor class ViewModel: ObservableObject {
        @Published var username = ""
        @Published var userPassword = ""
        @Published var showingConnectionError = false
        @Published var alertMessage = ""
    }
}
