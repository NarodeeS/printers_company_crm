//
//  TaskDetailsView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 09.11.2022.
//

import SwiftUI

struct TaskDetailsView: View {
    var selectedTask: Task
    var priorityCodes: [Int: String]
    var tasksTypes: [Int: String]
    var contracts: [Contract]
    var organizations: [Organization]
    
    @StateObject private var viewModel = ViewModel()
    @ObservedObject var workViewViewModel: WorkView.ViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            List {
                Group {
                    HStack {
                        Text("Creation date: ")
                            .bold()
                        Text(selectedTask.creationDate.formatted(date: .abbreviated, time: .omitted))
                    }
                    
                    if viewModel.enableDateSetting && selectedTask.taskStatus == 0 {
                        Toggle("Set completion date?", isOn: $viewModel.isCompletionDateSet.animation())
                    }
                    if viewModel.isCompletionDateSet {
                        DatePicker("Completion date",
                                   selection: $viewModel.plannedCompletionDate,
                                   in: Date()...,
                                   displayedComponents: [.date])
                    } else if let plannedDate = selectedTask.plannedVompletionDate {
                        HStack {
                            Text("Planned date: ")
                                .bold()
                            Text(plannedDate.formatted(date: .abbreviated, time: .omitted))
                        }
                    }
                    if selectedTask.taskStatus == 1 {
                        HStack {
                            Text("Completion date: ")
                                .bold()
                            if let completionDate = selectedTask.actualCompletionDate {
                                Text(completionDate.formatted(date: .abbreviated, time: .omitted))
                            }
                        }
                    }
                    
                    HStack {
                        HStack {
                            Text("Status: ")
                                .bold()
                            switch selectedTask.taskStatus {
                            case 0:
                                Text("Active")
                            default:
                                Text("Completed")
                            }
                        }
                    }
                }
                if viewModel.enableDetailsSetting && selectedTask.taskStatus == 0 {
                    TextField("Details", text: $viewModel.taskDetailsNew)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                } else {
                    HStack {
                        Text("Details: ")
                            .bold()
                        Text(selectedTask.tasksDetails)
                    }
                }
                HStack {
                    Text("Priority: ")
                        .bold()
                    Text(priorityCodes[selectedTask.priorityCode]!)
                }
                HStack {
                    Text("Task type :")
                        .bold()
                    Text(tasksTypes[selectedTask.taskTypeCode]!)
                }
                HStack {
                    Text("Contact person: ")
                        .bold()
                    if let person = viewModel.taskPerson {
                        Text("\(person.personName) (id: \(person.id))")
                    }
                }
                HStack {
                    Text("Contract: ")
                        .bold()
                    if let contractNumber = selectedTask.contractNumber,
                       let contract = contracts.first { $0.id == contractNumber },
                    let organization = organizations.first {$0.id == contract.organizationNumber} {
                        Text("\(contract.id) (\(organization.organizationName))")
                    }
                }
                HStack {
                    Text("Author: ")
                        .bold()
                    if let author = viewModel.taskAuthor {
                        Text("\(author.name) (login: \(author.login))")
                    }
                }
                if viewModel.enablePerformerSetting && selectedTask.taskStatus == 0 {
                    Toggle("Set performer?", isOn: $viewModel.isPerfomerSet.animation())
                }
                if viewModel.isPerfomerSet {
                    Picker("Performer", selection: $viewModel.performerCode) {
                        ForEach(Array(viewModel.employeesCodes.keys), id: \.self) { employeeCode in
                            Text("\(viewModel.employeesCodes[employeeCode]!.name) (login: \(viewModel.employeesCodes[employeeCode]!.login))")
                        }
                    }
                } else {
                    HStack {
                        Text("Performer: ")
                            .bold()
                        if let performer = viewModel.performerData {
                            Text("\(performer.name) (login: \(performer.login))")
                        }
                    }
                }
                if viewModel.taskPrinters.count > 0 {
                    Section("Participating printers") {
                        ForEach(Array(viewModel.taskPrinters.keys)) { printer in
                            VStack(alignment: .leading) {
                                Text("\(printer.manufacturer) \(printer.name)")
                                    .font(.headline)
                                Text("Count: \(viewModel.taskPrinters[printer]!)")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
            .listStyle(.inset)
            .navigationTitle("Task details")
        }
        .task {
            let dispatchQueue = DispatchQueue(label: "LoadingResources", qos: .background)
            dispatchQueue.async {
                DispatchQueue.main.async {
                    withAnimation {
                        viewModel.isLoading = true
                        if let person = viewModel.getContactPersonById(id: selectedTask.personNumber) {
                            viewModel.taskPerson = person
                        }
                        if let author = viewModel.getEmployeeById(id: selectedTask.authorNumber) {
                            viewModel.taskAuthor = author
                        }
                        if let performerNumber = selectedTask.performerNumber {
                            if let performer = viewModel.getEmployeeById(id: performerNumber) {
                                viewModel.performerData = performer
                            }
                        }
                        if let plannedDate = selectedTask.plannedVompletionDate {
                            viewModel.plannedCompletionDate = plannedDate
                        }
                        if let user = AppState.user {
                            if let employee = try? DatabaseAPI.getUserByLogin(login: user.username) {
                                viewModel.userData = employee
                                
                                if viewModel.userData!.role == .manager
                                    && (selectedTask.performerNumber == nil
                                        || selectedTask.authorNumber == viewModel.userData!.id){
                                    viewModel.enablePerformerSetting = true
                                } else { viewModel.enablePerformerSetting = false }
                                
                                if viewModel.userData!.id == selectedTask.authorNumber {
                                    viewModel.enableDateSetting = true
                                    viewModel.enableDetailsSetting = true
                                } else {
                                    viewModel.enableDateSetting = false
                                    viewModel.enableDetailsSetting = false
                                }
                            }
                        }
                        viewModel.taskDetailsNew = selectedTask.tasksDetails
                        viewModel.taskDetailsOld = selectedTask.tasksDetails
                        viewModel.loadEmployeesCodes()
                        viewModel.loadParticipatingPrinters(taskId: selectedTask.id)
                        viewModel.isLoading = false
                    }
                }
            }
        }
        .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(viewModel.alertMessage)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if let userData = viewModel.userData {
                    if (userData.id == selectedTask.authorNumber || userData.id == selectedTask.performerNumber)
                        && selectedTask.taskStatus == 0 {
                        Button("Mark as completed") {
                            let statement = "UPDATE tasks SET task_status = 1 WHERE (task_number = \(selectedTask.id));"
                            do {
                                try DatabaseAPI.executeStatement(statementText: statement)
                                viewModel.alertTitle = "Success"
                            } catch {
                                viewModel.alertTitle = "Error"
                                viewModel.alertMessage = "Can not set status"
                            }
                            
                            viewModel.showAlert = true
                        }
                    }
                }
                
                if viewModel.isPerfomerSet || viewModel.isCompletionDateSet
                    || (viewModel.taskDetailsOld != viewModel.taskDetailsNew) {
                    Button("Save") {
                        var statement = "UPDATE tasks SET "
                        if viewModel.taskDetailsOld != viewModel.taskDetailsNew {
                            statement += "task_details = '\(viewModel.taskDetailsNew)',"
                        }
                        if viewModel.isPerfomerSet {
                            statement += "performer_number = \(viewModel.performerCode),"
                        }
                        if viewModel.isCompletionDateSet {
                            statement += "planned_completion_date = DATE '\(viewModel.plannedCompletionDate.postgresDate(in: TimeZone.autoupdatingCurrent))',"
                        }
                        statement = String(statement.dropLast())
                        statement += " WHERE (task_number = \(selectedTask.id));"
                        do {
                            try DatabaseAPI.executeStatement(statementText: statement)
                            workViewViewModel.loadTasks()
                            viewModel.alertTitle = "Success"
                            viewModel.showAlert = true
                        } catch {
                            viewModel.alertTitle = "Error"
                            viewModel.alertMessage = error.localizedDescription
                            viewModel.showAlert = true
                        }
                    }
                }
            }
        }
    }
}
