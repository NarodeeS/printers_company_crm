//
//  ReportView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 11.11.2022.
//

import SwiftUI

struct ReportView: View {
    var selectedEmployee: Employee
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            Form {
                DatePicker("Start date", selection: $viewModel.startDate, displayedComponents: [.date])
                DatePicker("End date",
                           selection: $viewModel.endDate,
                           in: viewModel.startDate...,
                           displayedComponents: [.date])
                Button("Generate") {
                    withAnimation {
                        viewModel.loadEmployeeReport(employeeNumber: selectedEmployee.id)
                        viewModel.showReport = true
                    }
                }
            }
            if viewModel.showReport {
                List {
                    Section("Report details") {
                        ForEach(Array(viewModel.employeeReport.keys), id: \.self) { reportKey in
                            HStack {
                                Text(reportKey + ": ")
                                    .bold()
                                Text(String(viewModel.employeeReport[reportKey]!))
                            }
                        }
                    }
                }
            }
        }
        .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
            Button("OK") {}
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}
