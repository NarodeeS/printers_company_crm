//
//  ClientDetailsView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 05.11.2022.
//

import Foundation

extension ClientDetailsView {
    @MainActor class ViewModel: ObservableObject {
        @Published var user: User? = nil
    }
}
