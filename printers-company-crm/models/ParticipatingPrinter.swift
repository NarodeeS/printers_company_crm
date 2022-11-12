//
//  ParticipatingPrinter.swift
//  printers-company-crm
//
//  Created by George Stykalin on 08.11.2022.
//

import Foundation
import PostgresClientKit

class ParticipatingPrinter: Identifiable, RowDerivable {
    typealias DataType = ParticipatingPrinter
        
    let id = UUID()
    let printerNumber: Int64
    let taskNumber: Int64
    let amount: Int
    
    init(printerNumber: Int64, taskNumber: Int64, amount: Int) {
        self.printerNumber = printerNumber
        self.taskNumber = taskNumber
        self.amount = amount
    }
    
    static func createFromRow(row: Result<Row, Error>) throws -> ParticipatingPrinter {
        let columns = try row.get().columns
        let printerNumber = Int64(try columns[0].int())
        let taskNumber = Int64(try columns[1].int())
        let amount = try columns[2].int()
        
        return ParticipatingPrinter(printerNumber: printerNumber,
                                    taskNumber: taskNumber,
                                    amount: amount)
    }
    
    static func createGetByTaskIdStatement(taskId: Int64) -> String {
        return "SELECT * FROM participating_printers WHERE (task_number = \(taskId));"
    }
    
    static func createCreationStatement(printerNumber: Int64,
                                        taskNumber: Int64,
                                        count: Int) -> String {
        return "INSERT INTO participating_printers(printer_number, task_number, amount) "
             + "VALUES(\(printerNumber), \(taskNumber), \(count));"
    }
}
