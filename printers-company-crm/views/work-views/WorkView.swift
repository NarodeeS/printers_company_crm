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
            VStack {
                Picker("Pick view type", selection: $viewModel.viewType) {
                    ForEach(ViewType.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .padding(.bottom)
                .pickerStyle(.segmented)
                
                switch viewModel.viewType {
                case .tasks:
                    TasksView()
                case .contracts:
                    ContractsView()
                }
                Spacer()
            }
            .padding()
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
                    AddContractView()
                }
            }
            .onAppear {
                viewModel.user = AppState.user
            }
        }
    }
}

struct WorkView_Previews: PreviewProvider {
    static var previews: some View {
        WorkView()
    }
}
