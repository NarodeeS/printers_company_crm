//
//  Printer.swift
//  printers-company-crm
//
//  Created by George Stykalin on 07.11.2022.
//

import Foundation
import PostgresClientKit

class Printer: Identifiable, RowDerivable {
    static let getAllStatementText = "SELECT * FROM printers;"
    
    typealias DataType = Printer
    
    let id: Int64
    let manufacturer: String
    let name: String
    let paperWeight: Int
    let colorsNumber: Int
    let resolution: String
    let printSpeed: Int
    let cartridgeCount: Int
    let trayCapacity: Int
    let paperFormatCode: Int
    let printTechnologyCode: Int
    
    init(id: Int64, manufacturer: String,
         name: String, paperWeight: Int,
         colorsNumber: Int, resolution: String,
         printSpeed: Int, cartridgeCount: Int,
         trayCapacity: Int, paperFormatCode: Int,
         printTechnologyCode: Int) {
        
        self.id = id
        self.manufacturer = manufacturer
        self.name = name
        self.paperWeight = paperWeight
        self.colorsNumber = colorsNumber
        self.resolution = resolution
        self.printSpeed = printSpeed
        self.cartridgeCount = cartridgeCount
        self.trayCapacity = trayCapacity
        self.paperFormatCode = paperFormatCode
        self.printTechnologyCode = printTechnologyCode
    }
    
    static func createFromRow(row: Result<Row, Error>) throws -> Printer {
        let columns = try row.get().columns
        let id = Int64(try columns[0].int())
        let manufacturer = try columns[1].string()
        let printerName = try columns[2].string()
        let paperWeight = try columns[3].int()
        let colorsNumber = try columns[4].int()
        let resolution = try columns[5].string()
        let printSpeed = try columns[6].int()
        let cartridgeCount = try columns[7].int()
        let trayCapacity = try columns[8].int()
        let paperFormatCode = try columns[9].int()
        let printTechnologyCode = try columns[10].int()
        
        return Printer(id: id, manufacturer: manufacturer,
                       name: printerName, paperWeight: paperWeight,
                       colorsNumber: colorsNumber, resolution: resolution,
                       printSpeed: printSpeed, cartridgeCount: cartridgeCount,
                       trayCapacity: trayCapacity, paperFormatCode: paperFormatCode,
                       printTechnologyCode: printTechnologyCode)
    }
    
    static func createCreationStatement(manufacturer: String,
                                        name: String, paperWeight: Int,
                                        colorsNumber: Int, resolution: String,
                                        printSpeed: Int, cartridgeCount: Int,
                                        trayCapacity: Int, paperFormatCode: Int,
                                        printTechnologyCode: Int) -> String {
        return "INSERT INTO printers(manufacturer, printer_name, paper_weight, "
                                  + "colors_number, resolution, "
                                  + "print_speed, cartridge_count, "
                                  + "tray_capacity, paper_format_code, "
                                  + "print_technology_code)"
                        + " VALUES ('\(manufacturer)', '\(name)', "
                                  + "\(paperWeight), \(colorsNumber), "
                                  + "'\(resolution)', \(printSpeed), "
                                  + "\(cartridgeCount), \(trayCapacity), "
                                  + "\(paperFormatCode), \(printTechnologyCode));"
    }
}
