//
//  AddTaskView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 01.11.2022.
//

import SwiftUI
import PostgresClientKit

struct AddTaskView: View {
    private var tasksTypes = DatabaseAPI.getClassifierValues(tableName: "tasks_type_classifier")
    private var priorityCodes = DatabaseAPI.getClassifierValues(tableName: "priority_classifier")
    
    @StateObject private var viewModel = ViewModel()
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var workViewViewModel: WorkView.ViewModel
    
    init(workViewViewModel: WorkView.ViewModel) {
        self.workViewViewModel = workViewViewModel
    }

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                        .zIndex(1)
                }
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
                                       in: Date()...,
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
                            Toggle("Part of contract?", isOn: $viewModel.partOfContract.animation())
                                .onChange(of: viewModel.partOfContract) { changedValue in
                                    if changedValue {
                                        viewModel.loadPersonsByContractNumber(contractNumber: viewModel.contractNumber)
                                    } else {
                                        viewModel.loadPersons()
                                    }
                                }
                            if viewModel.partOfContract {
                                Picker("Contract", selection: $viewModel.contractNumber) {
                                    ForEach(Array(viewModel.contractsCodes.keys), id: \.self) { contractCode in
                                        if let contract = viewModel.contractsCodes[contractCode] {
                                            Text("Contract №" + String(contract.id))
                                        }
                                    }
                                }
                                .onChange(of: viewModel.contractNumber) { newContractNumber in
                                    viewModel.loadPersonsByContractNumber(contractNumber: newContractNumber)
                                }
                            }
                        }
                    }
                    if viewModel.partOfContract {
                        Section("Participating printers") {
                            List {
                                ForEach(Array(viewModel.participationPrinters.keys)) { printer in
                                    VStack(alignment: .leading) {
                                        Text("\(printer.manufacturer) \(printer.name)")
                                            .font(.headline)
                                        Text("Count: \(viewModel.participationPrinters[printer]!)")
                                            .font(.subheadline)
                                    }
                                }
                                .onDelete(perform: onParticipatingPrinterDelete)
                            }
                        }
                    }
                    Button("Submit") {
                        var creationStatement = Task
                            .createCreationStatement(
                                plannedCompletionDate: viewModel.setDate ? viewModel.plannedCompletionDate : nil,
                                taskDetails: viewModel.taskDetails,
                                priorityCode: viewModel.priorityCode,
                                taskTypeCode: viewModel.taskType,
                                personNumber: viewModel.personNumber,
                                contractNumber: viewModel.partOfContract ? viewModel.contractNumber : nil,
                                authorNumber: viewModel.userId!)
                        do {
                            let taskId = try DatabaseAPI.executeStatementWithResultId(statementText: creationStatement)
                            for (printer, count) in viewModel.participationPrinters {
                                creationStatement = ParticipatingPrinter
                                    .createCreationStatement(printerNumber: printer.id,
                                                             taskNumber: taskId,
                                                             count: count)
                                try DatabaseAPI.executeStatement(statementText: creationStatement)
                            }
                            viewModel.alertTitle = "Success"
                            viewModel.alertMessage = "Task created"
                            workViewViewModel.loadTasks()
                        } catch PostgresError.sqlError(let notice) {
                            viewModel.alertTitle = "Error"
                            viewModel.alertMessage = notice.detail ?? "Unknown"
                        } catch {
                            viewModel.alertTitle = "Error"
                            viewModel.alertMessage = "Unknown error"
                        }
                        viewModel.showFinalAlert = true
                    }
                }
                .zIndex(0)
            }
            .navigationTitle("New task")
            .navigationBarTitleDisplayMode(.large)
            .alert(viewModel.alertTitle, isPresented: $viewModel.showFinalAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(viewModel.alertMessage)
            }
            .task {
                let dispatchQueue = DispatchQueue(label: "Loading resources", qos: .background)
                dispatchQueue.async {
                    DispatchQueue.main.async {
                        withAnimation {
                            viewModel.isLoading = true
                            if let user = AppState.user {
                                let employees = DatabaseAPI
                                    .getDataObjects(statementText: Employee.getAllStatementText,
                                                    ofType: Employee.self)
                                for employee in employees {
                                    if employee.login == user.username {
                                        viewModel.userId = employee.id
                                    }
                                }
                            }
                            viewModel.loadPersons()
                            viewModel.loadContracts()
                            if viewModel.personsCodes.count == 0 {
                                viewModel.alertTitle = "Error"
                                viewModel.alertMessage = "You need to add at least one contact person"
                                viewModel.showFinalAlert = true
                            }
                            viewModel.personNumber = viewModel.personsCodes.first!.key
                            if viewModel.contractsCodes.count > 0 {
                                viewModel.enableContractSetting = true
                                viewModel.contractNumber = viewModel.contractsCodes.first!.key
                            }
                            viewModel.isLoading = false
                        }	
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.partOfContract {
                        Button("Add printer") {
                            viewModel.showAddPrinterSheet = true
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddPrinterSheet) {
                AddParticipatingPrinterView(addTaskViewViewModel: viewModel)
            }
        }
    }
    
    func onParticipatingPrinterDelete(indexSet: IndexSet) {
        indexSet.forEach { index in
            let printer = Array(viewModel.participationPrinters.keys)[index]
            viewModel.participationPrinters.removeValue(forKey: printer)
        }
    }
}

