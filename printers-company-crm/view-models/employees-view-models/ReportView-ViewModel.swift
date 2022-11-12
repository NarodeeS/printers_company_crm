//
//  ReportView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 11.11.2022.
//

import Foundation

extension ReportView {
    @MainActor class ViewModel: ObservableObject {
        @Published var startDate = Date()
        @Published var endDate = Date()
        @Published var showReport = false
        @Published var employeeReport = [String: Int]()
        @Published var showAlert = false
        @Published var alertTitle = ""
        @Published var alertMessage = ""
        
        func loadEmployeeReport(employeeNumber: Int) {
            do {
                employeeReport = try DatabaseAPI.getEmployeeReport(startDate: startDate,
                                                                   endDate: endDate,
                                                                   employeeNumber: employeeNumber)
            } catch {
                alertTitle = "Error"
                alertMessage = "Can not make report"
                showAlert = true
            }
        }
    }
}
