//
//  PrintersView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 07.11.2022.
//

import Foundation

extension PrintersView {
    @MainActor class ViewModel: ObservableObject {
        @Published var printers = [Printer]()
        @Published var paperFormatCodes = [Int: String]()
        @Published var printTechnologyCodes = [Int: String]()
        @Published var isLoading = true
        @Published var showAddingSheet = false
        
        func loadPrinters() {
            printers = DatabaseAPI
                .getDataObjects(statementText: Printer.getAllStatementText,
                                ofType: Printer.self)
        }
        
        func loadPaperFormatCodes() {
            paperFormatCodes = DatabaseAPI.getClassifierValues(tableName: "paper_format_classifier")
        }
        
        func getPaperFormatById(id: Int) -> String? {
            var paperFormat: String? = nil
            for (key, value) in paperFormatCodes {
                if key == id {
                    paperFormat = value
                }
            }
            return paperFormat
        }
        
        func getPrintTechnologyById(id: Int) -> String? {
            var printtechnology: String? = nil
            for (key, value) in printTechnologyCodes {
                if key == id {
                    printtechnology = value
                }
            }
            return printtechnology
        }
        
        func loadPrintTechnologyCodes() {
            printTechnologyCodes = DatabaseAPI.getClassifierValues(tableName: "print_technology_classifier")
        }
    }
}
