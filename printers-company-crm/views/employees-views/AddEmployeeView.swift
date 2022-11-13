//
//  AddEmployeeView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 30.10.2022.
//

import SwiftUI
import PostgresClientKit

struct AddEmployeeView: View {
    private let passwordLength = 12
    private var positionsCodes = DatabaseAPI.getClassifierValues(tableName: "positions_classifier")
    
    @StateObject private var viewModel = ViewModel()
    @ObservedObject private var employeesViewViewModel: EmployeesView.ViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    private let phoneFieldFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ""
        return formatter
    }()
    
    init(viewModel: EmployeesView.ViewModel) {
        self.employeesViewViewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("User name", text: $viewModel.name)
                        .autocorrectionDisabled(true)
                    TextField("User surname", text: $viewModel.surname)
                        .autocorrectionDisabled(true)
                }
                Section {
                    TextField("Login", text: $viewModel.login)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                    HStack {
                        if viewModel.secured {
                            SecureField("Password", text: $viewModel.password)
                                .autocapitalization(.none)
                            
                        } else {
                            TextField("Password", text: $viewModel.password)
                                .autocapitalization(.none)

                        }
                        Button {
                            viewModel.secured.toggle()
                        } label: {
                            if viewModel.secured {
                                Image(systemName: "eye")
                            } else {
                                Image(systemName: "eye.slash")
                            }
                        }
                    }
                    Button("Generate password") {
                        viewModel.setGeneratedPassword(length: passwordLength)
                    }
                }
                Section {
                    TextField("Email", text: $viewModel.email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    TextField("Phone number", value: $viewModel.mobile.value, formatter: phoneFieldFormatter)
                        .autocorrectionDisabled(true)
                        .keyboardType(.numberPad)
                    Picker("Role", selection: $viewModel.positionCode) {
                        ForEach(Array(positionsCodes.keys), id: \.self) {
                            if let value = positionsCodes[$0] {
                                Text(value)
                            }
                        }
                    }
                    Button("Submit") {
                        do {
                            let creationStatementText = Employee
                                .getCreateStatementText(name: viewModel.name,
                                                        surname: viewModel.surname,
                                                        login: viewModel.login,
                                                        password: viewModel.password,
                                                        mobile: viewModel.mobile.value,
                                                        email: viewModel.email,
                                                        positionCode: viewModel.positionCode)
                            try DatabaseAPI.executeStatement(statementText: creationStatementText)
                            employeesViewViewModel.loadEmployees()
                            viewModel.alertTitle = "New user created"
                            viewModel.alertMessage = "Do not forget to give login and password to the employee"
                        } catch PostgresError.sqlError(let notice) {
                            viewModel.alertTitle = "Error"
                            viewModel.alertMessage = notice.detail ?? "Unknown"
                        }
                        catch {
                            viewModel.alertTitle = "Error"
                            viewModel.alertMessage = "Unknown error"
                        }
                        viewModel.showingAlert.toggle()
                    }
                }
            }
            .navigationTitle("Create a new user")
            .alert(viewModel.alertTitle, isPresented: $viewModel.showingAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
}
