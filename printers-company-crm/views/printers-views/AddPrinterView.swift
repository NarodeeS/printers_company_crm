//
//  AddPrinterView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 07.11.2022.
//

import SwiftUI

struct AddPrinterView: View {
    @ObservedObject var printersViewViewModel: PrintersView.ViewModel
    var paperFormatCodes: [Int: String]
    var printTechnologyCodes: [Int: String]
    
    @StateObject private var viewModel = ViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Group {
                    TextField("Manufacturer", text: $viewModel.manufacturer)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                    TextField("Printer name", text: $viewModel.printerName)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                    TextField("Paper weight", value: $viewModel.paperWeight, format: .number)
                    TextField("Colors number", value: $viewModel.colorsNumber, format: .number)
                    TextField("Resolution", text: $viewModel.resolution)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                    TextField("Print speed", value: $viewModel.printSpeed, format: .number)
                    TextField("Cartridge count", value: $viewModel.cartidgeCount, format: .number)
                    TextField("Tray capactity", value: $viewModel.trayCpaacity, format: .number)
                }
                Picker("Paper format", selection: $viewModel.paperFormatCode) {
                    ForEach(Array(paperFormatCodes.keys), id: \.self) { paperFormatCode in
                        Text(paperFormatCodes[paperFormatCode]!)
                    }
                }
                Picker("Print technology", selection: $viewModel.printTechnologyCode) {
                    ForEach(Array(printTechnologyCodes.keys), id: \.self) { printTechnologyCode in
                        Text(printTechnologyCodes[printTechnologyCode]!)
                    }
                }
                Button("Submit") {
                    let creationStatement = Printer
                        .createCreationStatement(manufacturer: viewModel.manufacturer,
                                                 name: viewModel.printerName,
                                                 paperWeight: viewModel.paperWeight,
                                                 colorsNumber: viewModel.colorsNumber,
                                                 resolution: viewModel.resolution,
                                                 printSpeed: viewModel.printSpeed,
                                                 cartridgeCount: viewModel.cartidgeCount,
                                                 trayCapacity: viewModel.trayCpaacity,
                                                 paperFormatCode: viewModel.paperFormatCode,
                                                 printTechnologyCode: viewModel.printTechnologyCode)
                    
                    do {
                        try DatabaseAPI.executeStatement(statementText: creationStatement)
                        printersViewViewModel.loadPrinters()
                        viewModel.alertTitle = "Success"
                        viewModel.alertMessage = "Printer created"
                    } catch {
                        viewModel.alertTitle = "Error"
                        viewModel.alertMessage = error.localizedDescription
                    }
                    viewModel.showAlert = true
                }
            }
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(viewModel.alertMessage)
            }
            .navigationTitle("New printer")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
