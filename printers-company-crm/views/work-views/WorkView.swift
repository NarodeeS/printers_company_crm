//
//  WorkView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 04.11.2022.
//

import SwiftUI

struct WorkView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                        .zIndex(1)
                }
                VStack {
                    Picker("Pick view type", selection: $viewModel.viewType) {
                        ForEach(ViewType.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .padding()
                    .pickerStyle(.segmented)
                    switch viewModel.viewType {
                    case .tasks:
                        List {
                            ForEach(viewModel.tasks) { task in
                                NavigationLink {
                                    
                                } label: {
                                    VStack(alignment: .leading) {
                                        if let taskType = viewModel.tasksTypes[task.taskTypeCode],
                                           let priority = viewModel.priorityCodes[task.priorityCode] {
                                            HStack {
                                                Text(taskType)
                                                Spacer()
                                                Text(priority)
                                            }
                                            .bold()
                                            if let plannedDate = task.plannedVompletionDate {
                                                Text(plannedDate.formatted())
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .refreshable {
                            viewModel.loadTasks()
                        }
                    case .contracts:
                        List {
                            ForEach(viewModel.contracts) { contract in
                                NavigationLink {
                                    if let organization = viewModel.getOrganizationById(id: contract.organizationNumber) {
                                        ContractDetailsView(selectedContract: contract, organization: organization)
                                    }
                                } label: {
                                    VStack(alignment: .leading) {
                                        Text("Contract №" + String(contract.id))
                                            .bold()
                                        if let organization = viewModel.getOrganizationById(id: contract.organizationNumber) {
                                            Text("Organization: " + organization.organizationName
                                                + " (id: \(organization.id))")
                                        }
                                    }
                                }
                            }
                        }
                        .refreshable {
                            viewModel.loadContracts()
                            viewModel.loadOrganizations()
                        }
                    }
                    Spacer()
                }
                .zIndex(0)
            }
            .navigationTitle("Work")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let user = viewModel.user {
                        if user.role == .manager {
                            Button {
                                viewModel.showAddView.toggle()
                            } label: {
                                Image(systemName: viewModel.viewType == .tasks ? "plus" : "doc.badge.plus")
                            }
                        } else if user.role == .worker && viewModel.viewType == .tasks {
                            Button {
                                viewModel.showAddView.toggle()
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddView) {
                switch viewModel.viewType {
                case .tasks:
                    AddTaskView()
                case .contracts:
                    AddContractView(workViewViewModel: viewModel)
                }
            }
            .task {
                let dispatchQueue = DispatchQueue(label: "Loading resources", qos: .background)
                dispatchQueue.async {
                    DispatchQueue.main.async {
                        viewModel.isLoading = true
                        viewModel.loadTaskTypes()
                        viewModel.loadPriorityCodes()
                        viewModel.user = AppState.user
                        viewModel.loadTasks()
                        viewModel.loadContracts()
                        viewModel.loadOrganizations()
                        viewModel.isLoading = false
                    }
                }
            }
        }
    }
}

struct WorkView_Previews: PreviewProvider {
    static var previews: some View {
        WorkView()
    }
}
