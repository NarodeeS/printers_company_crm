//
//  ClientDetailsView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 05.11.2022.
//

import Foundation

extension ClientDetailsView {
    @MainActor class ViewModel: ObservableObject {
        @Published var contactPersons = [ContactPerson]()
        @Published var organization: Organization? = nil
        @Published var showAddPersonView = false
        @Published var user: User? = nil
        
        func loadContactPersons() {
            if let organization = organization {
                contactPersons = DatabaseAPI
                    .getDataObjects(statementText: ContactPerson.createGetByOrgNumberStatement(orgNumber: organization.id),
                                    ofType: ContactPerson.self)
            }
        }
    }
}
