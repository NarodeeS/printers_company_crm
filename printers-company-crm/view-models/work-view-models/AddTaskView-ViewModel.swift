//
//  AddTaskView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 03.11.2022.
//

import Foundation

extension AddTaskView {
    @MainActor class ViewModel: ObservableObject {
        @Published var user: User? = nil
        @Published var personsCodes = [Int64: ContactPerson]()
        @Published var contractsCodes = [Int: Contract]()
        @Published var showFinalAlert = false
        @Published var alertTitle = ""
        @Published var alertMessage = ""
        @Published var taskType = 1
        @Published var priorityCode = 1
        @Published var taskDetails = ""
        @Published var plannedCompletionDate = Date()
        @Published var personNumber: Int64 = 1
        @Published var contractNumber = 1
        @Published var partOfContract = false
        @Published var enableContractSetting = false
        @Published var setDate = false
        @Published var showAddPrinterSheet = false
        @Published var isLoading = false
        
        func loadPersons() {
            let persons = DatabaseAPI.getDataObjects(statementText: ContactPerson.getAllStatementText,
                                                     ofType: ContactPerson.self)
            
            for person in persons {
                personsCodes[person.id] = person
            }
        }
        
        func loadContracts() {
            let contracts = DatabaseAPI.getDataObjects(statementText: Contract.getAllStatementText,
                                                   ofType: Contract.self)
            
            for contract in contracts {
                contractsCodes[contract.id] = contract
            }
        }
    }
}
