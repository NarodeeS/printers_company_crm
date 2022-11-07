//
//  AddPrinterView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 07.11.2022.
//

import Foundation

extension AddPrinterView {
    @MainActor class ViewModel: ObservableObject {
        @Published var manufacturer = ""
        @Published var printerName = ""
        @Published var paperWeight = 0
        @Published var colorsNumber = 0
        @Published var resolution = ""
        @Published var printSpeed = 0
        @Published var cartidgeCount = 0
        @Published var trayCpaacity = 0
        @Published var paperFormatCode = 1
        @Published var printTechnologyCode = 1
        @Published var showAlert = false
        @Published var alertTitle = ""
        @Published var alertMessage = ""
    }
}
