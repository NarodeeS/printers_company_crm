//
//  AddTaskView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 03.11.2022.
//

import Foundation

extension AddTaskView {
    @MainActor class ViewModel: ObservableObject {
        @Published var taskType = 1
        @Published var priorityCode = 1
        @Published var taskDetails = ""
        @Published var plannedCompletionDate = Date()
        @Published var personNumber = 1
        @Published var contractNumber = 1
    }
}
