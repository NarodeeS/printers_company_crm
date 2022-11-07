//
//  MainView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 02.11.2022.
//

import Foundation

extension MainView {
    @MainActor class ViewModel: ObservableObject {
        @Published var tabSelection = 1
        @Published var showingLoginSheet = false
        @Published var user: User?
        
        func setUser() {
            user = AppState.user
        }
    }
}
