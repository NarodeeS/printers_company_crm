//
//  TasksView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 03.11.2022.
//

import Foundation

extension TasksView {
    @MainActor class ViewModel: ObservableObject {
        @Published var showingAddTaskSheet = false
        @Published var user: User? = nil
    }
}
