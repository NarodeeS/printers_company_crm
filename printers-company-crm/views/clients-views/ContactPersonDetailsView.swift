//
//  ContactPersonDetailsView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 06.11.2022.
//

import SwiftUI

struct ContactPersonDetailsView: View {
    var contactPerson: ContactPerson
    
    var body: some View {
        List {
            HStack {
                Text("Person ID: ")
                    .bold()
                Text(String(contactPerson.id))
            }
            HStack {
                Text("Mobile phone: ")
                    .bold()
                Text(String(contactPerson.personMobileNumber))
            }
            HStack {
                Text("Email: ")
                    .bold()
                Text(String(contactPerson.personEmail))
            }
            HStack {
                Text("Mail address: ")
                    .bold()
                Text(String(contactPerson.personMail))
            }
        }
        .listStyle(.inset)
        .navigationTitle(contactPerson.personName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
