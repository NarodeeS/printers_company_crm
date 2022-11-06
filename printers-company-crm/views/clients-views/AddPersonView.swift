//
//  AddPersonView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 06.11.2022.
//

import SwiftUI

struct AddPersonView: View {
    var organizationNumber: Int
    
    @StateObject private var viewModel = ViewModel()
    @ObservedObject var clientDetailsViewViewModel: ClientDetailsView.ViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    private let phoneFieldFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ""
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Person name", text: $viewModel.personName)
                    .autocorrectionDisabled(true)
                TextField("Person mobile", value: $viewModel.personMobile.value, formatter: phoneFieldFormatter)
                TextField("Person email", text: $viewModel.personEmail)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                TextField("Person mail address", text: $viewModel.personMail)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                Button("Submit") {
                    let creatingStatement = ContactPerson
                        .createCreationStatement(personName: viewModel.personName,
                                                 personMobile: viewModel.personMobile.value,
                                                 personEmail: viewModel.personEmail,
                                                 personMail: viewModel.personMail,
                                                 organizationNumber: organizationNumber)
                    
                    do {
                        try DatabaseAPI.executeStatement(statementText: creatingStatement)
                        clientDetailsViewViewModel.loadContactPersons()
                        viewModel.alertTitle = "Success"
                        viewModel.alertMessage = "New contact person created"
                    } catch {
                        viewModel.alertTitle = "Error"
                        viewModel.alertMessage = error.localizedDescription
                    }
                    viewModel.showAlert = true
                }
            }
            .navigationTitle("New contact person")
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
