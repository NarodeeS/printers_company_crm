//
//  AddParticipationPrinterView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 08.11.2022.
//

import SwiftUI

struct AddParticipatingPrinterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ViewModel()
    @ObservedObject var addTaskViewViewModel: AddTaskView.ViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Picker("Printer", selection: $viewModel.printerNumber) {
                        ForEach(Array(viewModel.printersNumbers.keys), id: \.self) { printerNumber in
                            if let printer = viewModel.printersNumbers[printerNumber] {
                                Text("\(printer.manufacturer) \(printer.name)")
                            }
                        }
                    }
                    TextField("Count", value: $viewModel.count, format: .number)
                    Button("Submit") {
                        addTaskViewViewModel
                            .addParticipatingPrinter(
                                printer: viewModel.printersNumbers[viewModel.printerNumber]!,
                                count: viewModel.count
                            )
                        viewModel.alertTitle = "Success"
                        viewModel.alertMessage = "New participating printer added"
                        viewModel.showAlert = true
                    }
                }
            }
            .navigationTitle("New printer")
            .navigationBarTitleDisplayMode(.large)
            .task {
                let dispatchQueue = DispatchQueue(label: "Loading resources", qos: .background)
                dispatchQueue.async {
                    DispatchQueue.main.async {
                        viewModel.isLoading = true
                        viewModel.loadPrintersNumbers()
                        if viewModel.printersNumbers.count == 0 {
                            viewModel.alertTitle = "Error"
                            viewModel.alertMessage = "To add participating printer you need to have at least one printer"
                            viewModel.showAlert = true
                        }
                        viewModel.isLoading = false
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
        }
    }
}
