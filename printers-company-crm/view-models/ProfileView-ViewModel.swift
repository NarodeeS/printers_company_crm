//
//  ProfileView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 02.11.2022.
//

import Foundation

extension ProfileView {
    @MainActor class ViewModel: ObservableObject {
        @Published var user: User? = nil
        @Published var employeeInfo: Employee? = nil
        @Published var isLoading = false
    }
}
