//
//  ProfileView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 02.11.2022.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ViewModel()
    @ObservedObject var mainViewViewModel: MainView.ViewModel
    
    var body: some View {
        NavigationView {
            HStack {
                VStack(alignment: .leading) {
                    if let user = viewModel.user {
                        if user.role == .admin {
                            Text("Login: " + user.username)
                                .font(.title2)
                                .padding(.bottom)
                            Text("Role: " + user.role.rawValue)
                                .font(.title2)
                        } else {
                            if let user = viewModel.employeeInfo {
                                HStack {
                                    Text(user.name)
                                    Text(user.surname)
                                }
                                .font(.title)
                                .padding()
                                List {
                                    HStack {
                                        Text("Login: ")
                                            .bold()
                                        Text(user.login)
                                    }
                                    HStack {
                                        Text("Phone number: ")
                                            .bold()
                                        Text(String(user.mobile))
                                    }
                                    HStack {
                                        Text("Email: ")
                                            .bold()
                                        Text(user.email)
                                    }
                                    HStack {
                                        Text("Role: ")
                                            .bold()
                                        Text(user.role.rawValue)
                                    }
                                }
                                .listStyle(.inset)
                            }
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if let user = viewModel.user {
                            user.delete()
                            AppState.user = nil
                            mainViewViewModel.showingLoginSheet.toggle()
                        }
                    } label: {
                        Image(systemName: "person.fill.badge.minus")
                    }
                }
            }
            .onAppear {
                if let user = AppState.user {
                    viewModel.user = user
                    
                    if let employee = try? DatabaseAPI.getUserByLogin(login: viewModel.user!.username) {
                        viewModel.employeeInfo = employee
                    }
                }
            }
        }
    }
}
