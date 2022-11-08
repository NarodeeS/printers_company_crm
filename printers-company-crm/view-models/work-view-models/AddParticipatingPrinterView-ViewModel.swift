//
//  AddParticipatingPrinterView-ViewModel.swift
//  printers-company-crm
//
//  Created by George Stykalin on 08.11.2022.
//

import SwiftUI

extension AddParticipatingPrinterView {
    @MainActor class ViewModel: ObservableObject {
        @Published var count = 0
    }
}
