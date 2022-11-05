//
//  TasksView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 22.10.2022.
//

import SwiftUI

struct TasksView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            List {
                
            }
            .onAppear {
                viewModel.user = AppState.user
            }
        }
    }
}
