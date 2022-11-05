//
//  AddContractView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 04.11.2022.
//

import Foundation

extension AddContractView {
    @MainActor class ViewModel: ObservableObject {
        @Published var contractDetails = ""
        @Published var organizationNumber = 1
    }
}
