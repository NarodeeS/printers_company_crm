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
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                        .zIndex(1)
                }
                List {
                    ForEach(viewModel.employee_list) { employee in
                        NavigationLink {
                            EmployeeDetailsView(employee: employee)
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
                .zIndex(0)
                .refreshable {
                    viewModel.loadEmployees()
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
            .task {
                let dispatchQueue = DispatchQueue(label: "Loading resources", qos: .background)
                dispatchQueue.async {
                    DispatchQueue.main.async {
                        withAnimation {
                            viewModel.isLoading = true
                            viewModel.loadEmployees()
                            viewModel.user = AppState.user
                            viewModel.isLoading = false
                        }
                    }
                }
            }
        }
    }
}
