//
//  PrinterDetailsView.swift
//  printers-company-crm
//
//  Created by George Stykalin on 07.11.2022.
//

import SwiftUI

struct PrinterDetailsView: View {
    var selectedPrinter: Printer
    var paperFormat: String
    var printTechnology: String
    
    var body: some View {
        List {
            HStack {
                Text("Paper weight: ")
                    .bold()
                Text(String(selectedPrinter.paperWeight))
            }
            HStack {
                Text("Colors number: ")
                    .bold()
                Text(String(selectedPrinter.colorsNumber))
            }
            HStack {
                Text("Resolution: ")
                    .bold()
                Text(selectedPrinter.resolution)
            }
            HStack {
                Text("Print speed: ")
                    .bold()
                Text(String(selectedPrinter.printSpeed))
            }
            HStack {
                Text("Cartridge count: ")
                    .bold()
                Text(String(selectedPrinter.cartridgeCount))
            }
            HStack {
                Text("Tray capacity: ")
                    .bold()
                Text(String(selectedPrinter.trayCapacity))
            }
            HStack {
                Text("Paper format: ")
                    .bold()
                Text(paperFormat)
            }
            HStack {
                Text("Print technology: ")
                    .bold()
                Text(printTechnology)
            }
        }
        .listStyle(.inset)
        .navigationTitle("\(selectedPrinter.manufacturer) \(selectedPrinter.name)")
        .navigationBarTitleDisplayMode(.inline)
    }
}
