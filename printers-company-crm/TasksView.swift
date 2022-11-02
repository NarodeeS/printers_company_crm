//
//  TasksView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 22.10.2022.
//

import SwiftUI

struct TasksView: View {
    var body: some View {
        NavigationView {
            List {
                
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if let userRole = AppState.user?.role {
                    if userRole != Role.admin {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                // Add task sheet
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
            }
        }
    }
}
