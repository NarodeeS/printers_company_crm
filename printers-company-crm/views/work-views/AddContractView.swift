//
//  AddContractView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 04.11.2022.
//

import SwiftUI

struct AddContractView: View {
    @StateObject private var viewModel = ViewModel()
    @ObservedObject var workViewViewModel: WorkView.ViewModel
    @Environment(\.dismiss) private var dissmiss
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                        .zIndex(1)
                }
                Form {
                    Section("Contract details") {
                        TextEditor(text: $viewModel.contractDetails)
                    }
                    Section {
                        Picker("Organization", selection: $viewModel.organizationNumber) {
                            ForEach(Array(viewModel.organizationCodes.keys), id: \.self) { organizationNumber in
                                if let organization = viewModel.organizationCodes[organizationNumber] {
                                    Text(organization.organizationName + " (\(organization.organizationEmail))")
                                }
                            }
                        }
                        Button("Submit") {
                            let creationStatement = Contract
                                .createCreationStatement(contractDetails: viewModel.contractDetails,
                                                         organizationNumber: viewModel.organizationNumber)
                            do {
                                try DatabaseAPI.executeStatement(statementText: creationStatement)
                                workViewViewModel.loadContracts()
                                viewModel.alertTitle = "Success"
                                viewModel.alertMessage = "Contract created"
                            } catch {
                                workViewViewModel.loadContracts()
                                viewModel.alertTitle = "Error"
                                viewModel.alertMessage = error.localizedDescription
                            }
                            viewModel.showAlert = true
                        }
                    }
                }
                .zIndex(0)
            }
            .navigationTitle("New contract")
            .task {
                let dispatchQueue = DispatchQueue(label: "Loading resources", qos: .background)
                dispatchQueue.async {
                    DispatchQueue.main.async {
                        viewModel.isLoading = true
                        viewModel.loadOrganizations()
                        if viewModel.organizationCodes.count == 0 {
                            viewModel.alertTitle = "Error"
                            viewModel.alertMessage = "To create contract you need to have at least one client"
                            viewModel.showAlert = true
                        } else {
                            viewModel.organizationNumber = viewModel.organizationCodes.keys.first!
                        }
                        viewModel.isLoading = false
                    }
                }
            }
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
                Button("OK") {
                    dissmiss()
                }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
}
