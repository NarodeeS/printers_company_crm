//
//  Employees.swift
//  printers-company-crm
//
//  Created by George Stykalin on 01.11.2022.
//

import Foundation

class Employees: ObservableObject {
    @Published var employee_list = [Employee]()
}
