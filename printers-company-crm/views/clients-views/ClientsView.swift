//
//  ClientsView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 04.11.2022.
//

import SwiftUI

struct ClientsView: View {
    @StateObject private var viewModel = ViewModel()
        
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.organizations) { organization in
                    NavigationLink {
                        ClientDetailsView(organization: organization)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(organization.organizationName)
                                .font(.headline)
                            Text(organization.organizationEmail)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Clients")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let user = viewModel.user {
                        if user.role == .manager {
                            Button {
                                viewModel.showAddView = true
                            } label: {
                                Image(systemName: "plus.app.fill")
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddView) {
                AddClientView(clientsViewViewModel: viewModel)
            }
            .refreshable {
                viewModel.loadOrganizations()
            }
            .onAppear {
                viewModel.loadOrganizations()
                if let user = AppState.user {
                    viewModel.user = user
                }
            }
        }
    }
}

struct ClientsView_Previews: PreviewProvider {
    static var previews: some View {
        ClientsView()
    }
}
