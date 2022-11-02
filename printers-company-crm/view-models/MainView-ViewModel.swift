//
//  MainView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 02.11.2022.
//

import Foundation

extension MainView {
    @MainActor class ViewModel: ObservableObject {
        @Published var showingLoginSheet = false
    }
}
