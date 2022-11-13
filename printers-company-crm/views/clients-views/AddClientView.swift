//
//  AddClientView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 05.11.2022.
//

import SwiftUI
import PostgresClientKit

struct AddClientView: View {
    @StateObject private var viewModel = ViewModel()
    @ObservedObject var clientsViewViewModel: ClientsView.ViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Organization name", text: $viewModel.organizationName)
                    .autocorrectionDisabled(true)
                TextField("Organization email", text: $viewModel.organizationEmail)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                TextField("Organization mail address", text: $viewModel.organizationMail)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                TextField("Organization city", text: $viewModel.organizationCity)
                Picker("Organization Status", selection: $viewModel.organizationStatus) {
                    ForEach(Array(Organization.OrganizationStatus.allCases), id: \.self) {
                        Text($0.rawValue)
                    }
                }
                Button("Submit") {
                    let creationStatement = Organization
                        .getCreateStatementText(organizationName: viewModel.organizationName,
                                                organizationEmail: viewModel.organizationMail,
                                                organizationMail: viewModel.organizationMail,
                                                organizationCity: viewModel.organizationCity,
                                                organizationStatus: viewModel.organizationStatus)
                    do {
                        try DatabaseAPI.executeStatement(statementText: creationStatement)
                        clientsViewViewModel.loadOrganizations()
                        viewModel.alertTitle = "Success"
                        viewModel.alertMessage = "Client created"
                    } catch PostgresError.sqlError(let notice) {
                        viewModel.alertTitle = "Error"
                        viewModel.alertMessage = notice.detail ?? "Unknown"
                    } catch {
                        viewModel.alertTitle = "Error"
                        viewModel.alertMessage = "Unknown error"
                    }
                    viewModel.showAlert.toggle()
                }
            }
            .navigationTitle("New client")
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
}

