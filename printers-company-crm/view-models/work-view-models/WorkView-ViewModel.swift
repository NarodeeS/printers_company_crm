//
//  WorkView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 04.11.2022.
//

import Foundation

extension WorkView {
    enum ViewType: String, CaseIterable {
        case tasks = "Tasks"
        case contracts = "Contracts"
    }
    
    @MainActor class ViewModel: ObservableObject {
        @Published var viewType = ViewType.tasks
        @Published var showAddView = false
        @Published var user: User? = nil
        @Published var tasks = [Task]()
        @Published var contracts = [Contract]()
        @Published var organizations = [Organization]()
        @Published var tasksTypes = [Int: String]()
        @Published var priorityCodes = [Int: String]()
        @Published var isLoading = false
        
        func getOrganizationById(id: Int) -> Organization? {
            if let organizationIndex = organizations
                .firstIndex(where: {$0.id == id}) {
                return organizations[organizationIndex]
            } else {
                return nil
            }
        }
        
        func loadPriorityCodes() {
            priorityCodes = DatabaseAPI.getClassifierValues(tableName: "priority_classifier")
        }
        
        func loadTaskTypes() {
            tasksTypes = DatabaseAPI.getClassifierValues(tableName: "tasks_type_classifier")
        }
        
        func loadTasks() {
            tasks = DatabaseAPI.getDataObjects(statementText: Task.getAllStatementText,
                                               ofType: Task.self)
        }
        
        func loadContracts() {
            contracts = DatabaseAPI.getDataObjects(statementText: Contract.getAllStatementText,
                                                   ofType: Contract.self)
        }
        
        func loadOrganizations() {
            organizations = DatabaseAPI
                .getDataObjects(statementText: Organization.getAllStatementText,
                                ofType: Organization.self)
        }
    }
}
