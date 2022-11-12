//
//  UserView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 30.10.2022.
//

import SwiftUI

struct EmployeeDetailsView: View {
    var employee: Employee
    
    var body: some View {
        List {
            HStack {
                Text("Login: ")
                    .bold()
                Text(employee.login)
            }
            HStack {
                Text("Mobile phone: ")
                    .bold()
                Text(String(employee.mobile))
            }
            HStack {
                Text("Email: ")
                    .bold()
                Text(employee.email)
            }
            HStack {
                Text("Role: ")
                    .bold()
                Text(employee.role.rawValue)
            }
            NavigationLink {
                ReportView(selectedEmployee: employee)
            } label: {
                Text("View report")
            }
        }
        .listStyle(.inset)
        .navigationTitle("\(employee.name) \(employee.surname)")
        .navigationBarTitleDisplayMode(.inline)
    }
}
