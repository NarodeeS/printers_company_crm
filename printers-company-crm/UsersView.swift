//
//  UsersView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 30.10.2022.
//

import SwiftUI

struct UsersView: View {
    @StateObject private var employees: Employees = Employees()
    @State private var showingCreateUserView = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(employees.employee_list) { employee in
                    NavigationLink {
                        Text("Employee info")
                    } label: {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(employee.name)
                                Text(employee.surname)
                                Spacer()
                            }
                            .font(.headline)
                            Text(employee.role.rawValue)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Users")
            .toolbar {
                if let userRole = AppState.user?.role {
                    if userRole == Role.admin {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                showingCreateUserView = true
                            } label: {
                                Image(systemName: "person.crop.circle.badge.plus")
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCreateUserView) {
                AddUserView(employees: employees)
            }
            .onAppear {
                self.employees.employee_list = DatabaseAPI.getUsers()
            }
        }
    }
}
