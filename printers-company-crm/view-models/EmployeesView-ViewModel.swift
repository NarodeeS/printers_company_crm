//
//  Employees.swift
//  printers-company-crm
//
//  Created by George Stykalin on 01.11.2022.
//

import Foundation

extension EmployeesView {
    @MainActor class ViewModel: ObservableObject {
        @Published private(set) var employee_list = [Employee]()
        
        func loadEmployees() {
            employee_list = DatabaseAPI.getUsers()
        }
        
        func addEmployee(employee: Employee) {
            employee_list.append(employee)
        }
    }
}
