//
//  TaskDetailsView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 09.11.2022.
//

import Foundation

extension TaskDetailsView {
    enum TaskStatus: String, CaseIterable {
        case active = "Active"
        case completed = "Completed"
    }
    
    @MainActor class ViewModel: ObservableObject {
        @Published var userData: Employee? = nil
        @Published var authorData: Employee? = nil
        @Published var performerData: Employee? = nil
        @Published var taskPerson: ContactPerson? = nil
        @Published var taskAuthor: Employee? = nil
        @Published var isLoading = false
        @Published var enableDateSetting = false
        @Published var plannedCompletionDate = Date()
        @Published var taskDetailsNew = ""
        @Published var taskDetailsOld = ""
        @Published var isCompletionDateSet = false
        @Published var isPerfomerSet = false
        @Published var performerCode = 1
        @Published var employeesCodes = [Int: Employee]()
        @Published var taskPrinters = [Printer: Int]()
        
        @Published var showAlert = false
        @Published var alertTitle = ""
        @Published var alertMessage = ""
        
        @Published var enablePerformerSetting = false
        @Published var enableDetailsSetting = false
        
        func loadEmployeesCodes() {
            let statement = Employee.getAllStatementText
            let employees = DatabaseAPI.getDataObjects(statementText: statement,
                                                       ofType: Employee.self)
            if AppState.user!.role != .admin {
                for employee in employees {
                    if employee.role == .worker || (employee.id == userData!.id && userData!.role == .manager) {
                        employeesCodes[employee.id] = employee
                    }
                }
            }
        }
        
        func loadParticipatingPrinters(taskId: Int64) {
            let statement = ParticipatingPrinter.createGetByTaskIdStatement(taskId: taskId)
            let participatingPrinters = DatabaseAPI.getDataObjects(statementText: statement,
                                                               ofType: ParticipatingPrinter.self)
            let printers = DatabaseAPI.getDataObjects(
                statementText: Printer.getAllStatementText,
                ofType: Printer.self)
            
            for participatingPrinter in participatingPrinters {
                let optionalPrinter = printers.first { $0.id == participatingPrinter.printerNumber }
                if let printer = optionalPrinter {
                    taskPrinters[printer] = participatingPrinter.amount
                }
            }
        }
        
        func getContactPersonById(id: Int64) -> ContactPerson? {
            let statement = ContactPerson.createGetByIdStatement(id: id)
            let persons = DatabaseAPI.getDataObjects(statementText: statement,
                                                     ofType: ContactPerson.self)
            guard persons.count > 0 else {
                return nil
            }
            
            return persons[0]
        }
        
        func getEmployeeById(id: Int) -> Employee? {
            let statement = Employee.createGetByIdStatement(id: id)
            let employees = DatabaseAPI.getDataObjects(statementText: statement,
                                                       ofType: Employee.self)
            guard employees.count > 0 else {
                return nil
            }
            
            return employees[0]
        }
    }
}
