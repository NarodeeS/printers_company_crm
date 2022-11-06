//
//  AddTaskView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 01.11.2022.
//

import SwiftUI

struct AddTaskView: View {
    private var tasksTypes = DatabaseAPI.getClassifierValues(tableName: "tasks_type_classifier")
    private var priorityCodes = DatabaseAPI.getClassifierValues(tableName: "priority_classifier")
    
    @StateObject private var viewModel = ViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Task description") {
                    Picker("Task type", selection: $viewModel.taskType) {
                        ForEach(Array(tasksTypes.keys), id: \.self) {
                            if let value = tasksTypes[$0] {
                                Text(value)
                            }
                        }
                    }
                    Picker("Priority", selection: $viewModel.priorityCode) {
                        ForEach(Array(priorityCodes.keys), id: \.self) {
                            if let value = priorityCodes[$0] {
                                Text(value)
                            }
                        }
                    }
                }
                Section("Task details") {
                    TextEditor(text: $viewModel.taskDetails)
                    Toggle(isOn: $viewModel.setDate.animation()) {
                        Text("Enable date")
                    }
                    if viewModel.setDate {
                        DatePicker("Completion date",
                                   selection: $viewModel.plannedCompletionDate,
                                   displayedComponents: [.date])
                    }
                    Picker("Contact person", selection: $viewModel.personNumber) {
                        ForEach(Array(viewModel.personsCodes.keys), id: \.self) { personCode in
                            if let person = viewModel.personsCodes[personCode] {
                                Text(person.personName + " (id: \(person.id))")
                            }
                        }
                    }
                    if viewModel.enableContractSetting {
                        Picker("Contract", selection: $viewModel.contractNumber) {
                            ForEach(Array(viewModel.contractsCodes.keys), id: \.self) { contractCode in
                                if let contract = viewModel.contractsCodes[contractCode] {
                                    Text("Contract " + String(contract.id))
                                }
                            }
                        }
                    }
                }
                Button("Submit") {
                    // Create task
                }
            }
            .navigationTitle("New task")
            .navigationBarTitleDisplayMode(.large)
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(viewModel.alertMessage)
            }
            .onAppear {
                if let user = AppState.user {
                    viewModel.user = user
                }
                viewModel.loadPersons()
                viewModel.loadContracts()
                if viewModel.personsCodes.count == 0 {
                    viewModel.alertTitle = "Error"
                    viewModel.alertMessage = "You need to add at least one contact person"
                    viewModel.showAlert = true
                }
                viewModel.personNumber = viewModel.personsCodes.first!.key
                if viewModel.contractsCodes.count > 0 {
                    viewModel.enableContractSetting = true
                    viewModel.contractNumber = viewModel.contractsCodes.first!.key
                }
            }
        }
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
    }
}
