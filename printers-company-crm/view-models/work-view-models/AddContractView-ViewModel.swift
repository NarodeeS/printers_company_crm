//
//  AddContractView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 04.11.2022.
//

import Foundation

extension AddContractView {
    @MainActor class ViewModel: ObservableObject {
        @Published var contractDetails = ""
        @Published var organizationNumber = 1
        @Published var showAlert = false
        @Published var alertTitle = ""
        @Published var alertMessage = ""
        @Published var organizationCodes = [Int: Organization]()
        @Published var isLoading = false
        
        func loadOrganizations() {
            let organizations = DatabaseAPI
                .getDataObjects(statementText: Organization.getAllStatementText,
                                ofType: Organization.self)
            
            for organization in organizations {
                organizationCodes[organization.id] = organization
            }
        }
    }
}
