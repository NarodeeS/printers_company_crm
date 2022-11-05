//
//  ClientsView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 04.11.2022.
//

import Foundation

extension ClientsView {
    @MainActor class ViewModel: ObservableObject {
        @Published var showAddView = false
        @Published var organizations = [Organization]()
        @Published var user: User? = nil
        
        func loadOrganizations() {
            organizations = DatabaseAPI.getDataObjects(statementText: Organization.getAllStatementText,
                                                       ofType: Organization.self)
        }
    }
}
