//
//  AddParticipatingPrinterView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 08.11.2022.
//

import SwiftUI

extension AddParticipatingPrinterView {
    @MainActor class ViewModel: ObservableObject {
        @Published var count = 1
        @Published var printerNumber: Int64 = 1
        @Published var printersNumbers = [Int64: Printer]()
        @Published var isLoading = false
        @Published var showAlert = false
        @Published var alertTitle = ""
        @Published var alertMessage = ""
        
        func loadPrintersNumbers() {
            let printers = DatabaseAPI
                .getDataObjects(statementText: Printer.getAllStatementText,
                                ofType: Printer.self)
            
            for printer in printers {
                printersNumbers[printer.id] = printer
            }
        }
    }
}
