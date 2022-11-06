//
//  AddPersonView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 06.11.2022.
//

import Foundation

extension AddPersonView {
    @MainActor class ViewModel: ObservableObject {
        @Published var showAlert = false
        @Published var alertTitle = ""
        @Published var alertMessage = ""
        @Published var personName = ""
        @Published var personMobile = NumberLimiter(limit: 11)
        @Published var personEmail = ""
        @Published var personMail = ""
    }
}
