//
//  ClientDetailsView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 05.11.2022.
//

import SwiftUI

struct ClientDetailsView: View {
    @StateObject var viewModel = ViewModel()
    private var selectedOrganization: Organization
    
    init(organization: Organization) {
        selectedOrganization = organization
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
                    ForEach(viewModel.contactPersons) { person in
                        NavigationLink {
                            ContactPersonDetailsView(contactPerson: person)
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
                            viewModel.showAddPersonView = true
                        } label: {
                            Image(systemName: "person.fill.badge.plus")
                        }
                    }
                }
            }
        }
        .refreshable {
            viewModel.loadContactPersons()
        }
        .sheet(isPresented: $viewModel.showAddPersonView) {
            AddPersonView(organizationNumber: selectedOrganization.id,
                          clientDetailsViewViewModel: viewModel)
        }
        .onAppear {
            if let user = AppState.user {
                viewModel.user = user
            }
            viewModel.organization = selectedOrganization
            viewModel.loadContactPersons()
        }
    }
}
