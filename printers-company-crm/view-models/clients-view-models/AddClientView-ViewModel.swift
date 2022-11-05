//
//  AddClientView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 05.11.2022.
//

import Foundation

extension AddClientView {
    @MainActor class ViewModel: ObservableObject {
        @Published var organizationName: String = ""
        @Published var organizationEmail: String = ""
        @Published var organizationMail: String = ""
        @Published var organizationCity: String = ""
        @Published var organizationStatus: Organization.OrganizationStatus = .potential
        
        @Published var showAlert = false
        @Published var alertTitle = ""
        @Published var alertMessage = ""
    }
}
