//
//  ContactPersonsView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 04.11.2022.
//

import SwiftUI

struct ContactPersonsView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.persons) { person in
                    NavigationLink {
                        Text("Contact person info")
                    } label: {
                        VStack(alignment: .leading) {
                            Text(person.personName)
                                .font(.headline)
                        }
                    }
                }
            }
            .padding(.top)
            .onAppear {
                viewModel.loadPersons()
            }
        }
    }
}

struct ContactPersonsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactPersonsView()
    }
}
