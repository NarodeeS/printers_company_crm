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
                    DatePicker("Completion date",
                               selection: $viewModel.plannedCompletionDate,
                               displayedComponents: [.date])
                    
                }
                
                Button("Submit") {
                    // Create task
                }
            }
            .navigationTitle("New task")
            .navigationBarTitleDisplayMode(.large)
            
        }
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
    }
}
