//
//  ContractsView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 04.11.2022.
//

import Foundation

extension ContractsView {
    @MainActor class ViewModel: ObservableObject {
        @Published private(set) var contracts = [Contract]()
        @Published var showAddContractView = false
        
        func loadContracts() {
            contracts = DatabaseAPI.getDataObjects(statementText: Contract.getAllStatementText,
                                                   ofType: Contract.self)
        }
        
        func addContract(contract: Contract) {
            contracts.append(contract)
        }
    }
}
