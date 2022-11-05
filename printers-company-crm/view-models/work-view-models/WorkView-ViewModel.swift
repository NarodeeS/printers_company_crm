//
//  WorkView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 04.11.2022.
//

import Foundation

extension WorkView {
    enum ViewType: String, CaseIterable {
        case tasks = "Tasks"
        case contracts = "Contracts"
    }
    
    @MainActor class ViewModel: ObservableObject {
        @Published var viewType = ViewType.tasks
        @Published var showAddView = false
        @Published var user: User? = nil
    }
}
