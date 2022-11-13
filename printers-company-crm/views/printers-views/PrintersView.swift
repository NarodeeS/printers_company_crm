//
//  PrintersView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 07.11.2022.
//

import SwiftUI

struct PrintersView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                        .zIndex(1)
                }
                List {
                    ForEach(viewModel.printers) { printer in
                        NavigationLink {
                            if let paperFormat = viewModel.getPaperFormatById(id: printer.paperFormatCode),
                               let printTechnology = viewModel.getPrintTechnologyById(id: printer.printTechnologyCode) {
                                PrinterDetailsView(selectedPrinter: printer,
                                                   paperFormat: paperFormat,
                                                   printTechnology: printTechnology)
                            }
                        } label: {
                            VStack(alignment: .leading) {
                                Text(printer.name)
                                    .font(.headline)
                                Text(printer.manufacturer)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .zIndex(0)
                .refreshable {
                    viewModel.loadPrinters()
                }
            }
            .navigationTitle("Printers")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let user = AppState.user {
                        if user.role == .admin {
                            Button {
                                viewModel.showAddingSheet = true
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddingSheet){
                AddPrinterView(printersViewViewModel: viewModel,
                               paperFormatCodes: viewModel.paperFormatCodes,
                               printTechnologyCodes: viewModel.printTechnologyCodes)
            }
            .task {
                let dispatchQueue = DispatchQueue(label: "LoadingResources", qos: .background)
                dispatchQueue.async {
                    DispatchQueue.main.async {
                        withAnimation {
                            viewModel.isLoading = true
                            viewModel.loadPrinters()
                            viewModel.loadPaperFormatCodes()
                            viewModel.loadPrintTechnologyCodes()
                            viewModel.isLoading = false
                        }
                    }
                }
            }
        }
    }
}

struct PrintersView_Previews: PreviewProvider {
    static var previews: some View {
        PrintersView()
    }
}
