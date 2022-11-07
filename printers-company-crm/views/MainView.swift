//
//  MainView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 22.10.2022.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        TabView(selection: $viewModel.tabSelection) {
            ProfileView(mainViewViewModel: viewModel)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(1)
            
            WorkView()
                .tabItem {
                    Label("Work", systemImage: "tray.full.fill")
                }
                .tag(2)
            
            ClientsView()
                .tabItem{
                    Label("Clients", systemImage: "person.line.dotted.person")
                }
                .tag(3)
            
            EmployeesView()
                .tabItem {
                    Label("Users", systemImage: "person.3")
                }
                .tag(4)
            
            if let user = viewModel.user {
                if user.role == .admin {
                    PrintersView()
                        .tabItem {
                            Label("Printers", systemImage: "printer.fill")
                        }
                        .tag(5)
                }
            }
        }
        .sheet(isPresented: $viewModel.showingLoginSheet) {
            LoginView(tabSelection: $viewModel.tabSelection)
        }
        .onAppear{
            AppState.user = loadUser()
            if !AppState.userLoggedIn {
                viewModel.showingLoginSheet = true
            }
        }
    }
    
    func loadUser() -> User? {
        if let data = UserDefaults.standard.data(forKey: "user") {
            let decoder = JSONDecoder()
            if let decodedUser = try? decoder.decode(User.self, from: data) {
                return decodedUser
            }
        }
        return nil
    }
}
    

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
