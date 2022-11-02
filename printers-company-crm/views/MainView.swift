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
        TabView {
            TasksView()
                .tabItem {
                    Label("Tasks", systemImage: "tray.full.fill")
                }
            
            EmployeesView()
                .tabItem{
                    Label("Users", systemImage: "person.fill")
                }
        }
        .sheet(isPresented: $viewModel.showingLoginSheet) {
            LoginView()
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
