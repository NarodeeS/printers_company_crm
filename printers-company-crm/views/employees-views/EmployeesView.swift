//
//  UsersView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 30.10.2022.
//

import SwiftUI

struct EmployeesView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.employee_list) { employee in
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
                if let userRole = viewModel.user?.role {
                    if userRole == Role.admin {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                viewModel.showingCreateUserView = true
                            } label: {
                                Image(systemName: "person.fill.badge.plus")
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingCreateUserView) {
                AddEmployeeView(viewModel: viewModel)
            }
            .refreshable {
                viewModel.loadEmployees()
            }
            .onAppear {
                viewModel.loadEmployees()
                viewModel.user = AppState.user
            }
        }
    }
}
