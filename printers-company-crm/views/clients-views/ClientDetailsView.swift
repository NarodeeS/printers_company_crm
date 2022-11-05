//
//  ClientDetailsView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 05.11.2022.
//

import SwiftUI

struct ClientDetailsView: View {
    @StateObject var viewModel = ViewModel()
    @State private var selectedOrganization: Organization
    @State private var contactPersons: [ContactPerson]
    
    init(organization: Organization) {
        selectedOrganization = organization
        
        contactPersons = DatabaseAPI
            .getDataObjects(statementText: ContactPerson.getAllStatementText,
                            ofType: ContactPerson.self)
    }
    
    var body: some View {
            VStack {
                List {
                    Section("Organization details") {
                        HStack {
                            Text("Email: ")
                                .bold()
                            Text(selectedOrganization.organizationEmail)
                        }
                        HStack {
                            Text("Mail address: ")
                                .bold()
                            Text(selectedOrganization.organizationMail)
                        }
                        HStack {
                            Text("City: ")
                                .bold()
                            Text(selectedOrganization.organizationCity)
                        }
                        HStack {
                            Text("Status: ")
                                .bold()
                            Text(selectedOrganization.organizationStatus.rawValue)
                        }
                    }
                    Section("Contact persons") {
                        ForEach(contactPersons) { person in
                            NavigationLink {
                                // Show contact person details
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(person.personName)
                                        .bold()
                                    Text(person.personEmail)
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
        
        .navigationTitle(selectedOrganization.organizationName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let user = viewModel.user {
                    if user.role == .manager {
                        Button {
                            // Show contact person creation sheet
                        } label: {
                            Image(systemName: "person.fill.badge.plus")
                        }
                    }
                }
            }
        }
        .refreshable {
            contactPersons = DatabaseAPI
                .getDataObjects(statementText: ContactPerson.getAllStatementText,
                                ofType: ContactPerson.self)
        }
        .onAppear {
            if let user = AppState.user {
                viewModel.user = user
            }
        }
    }
}
