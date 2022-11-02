//
//  AddEmployeeView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 02.11.2022.
//

import Foundation

extension AddEmployeeView {
    @MainActor class ViewModel: ObservableObject {
        @Published var name = ""
        @Published var surname = ""
        @Published var login = ""
        @Published var password = ""
        @Published var secured = true
        @Published var mobilePhone = NumberLimiter(limit: 11)
        @Published var email = ""
        @Published var positionCode = 1
        @Published var showingAlert = false
        @Published var alertMessage = ""
        @Published var alertTitle = ""
        
        func setGeneratedPassword(length: Int) {
            let elements = "abcdefghijklmonpqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890@#%$()"
            var newPassword = ""
            for _ in 0..<length {
                newPassword.append(elements.randomElement()!)
            }
            password = newPassword
        }
    }
}
