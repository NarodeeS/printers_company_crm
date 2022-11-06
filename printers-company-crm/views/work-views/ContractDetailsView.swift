//
//  ContractDetailsView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 06.11.2022.
//

import SwiftUI

struct ContractDetailsView: View {
    var selectedContract: Contract
    var organization: Organization
    
    var body: some View {
        List {
            HStack {
                Text("Details: ")
                    .bold()
                Text(selectedContract.contractDetails)
            }
            HStack {
                Text("Organization: ")
                    .bold()
                Text(organization.organizationName + " (id: \(organization.id))")
            }
        }
        .navigationTitle("Contract №" + String(selectedContract.id))
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.inset)
    }
}
