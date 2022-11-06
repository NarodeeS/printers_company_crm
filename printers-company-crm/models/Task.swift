//
//  Task.swift
//  printers-company-crm
//
//  Created by George Stykalin on 03.11.2022.
//

import Foundation
import PostgresClientKit

class Task: Identifiable, RowDerivable {
    typealias DataType = Task
    
    static let getAllStatementText = "SELECT * FROM tasks;"
    
    let id: Int64
    let creationDate: Date
    var plannedVompletionDate: Date? = nil
    var actualCompletionDate: Date? = nil
    var taskStatus: Int
    var tasksDetails: String
    let priorityCode: Int
    let taskTypeCode: Int
    let personNumber: Int64
    let contractNumber: Int?
    let authorNumber: Int
    var performerNumber: Int? = nil
    
    init(id: Int64, creationDate: Date,
         plannedVompletionDate: Date?, actualCompletionDate: Date? = nil,
         taskStatus: Int, tasksDetails: String,
         priorityCode: Int, taskTypeCode: Int,
         personNumber: Int64, contractNumber: Int? = nil,
         authorNumber: Int) {
        self.id = id
        self.creationDate = creationDate
        self.plannedVompletionDate = plannedVompletionDate
        self.actualCompletionDate = actualCompletionDate
        self.taskStatus = taskStatus
        self.tasksDetails = tasksDetails
        self.priorityCode = priorityCode
        self.taskTypeCode = taskTypeCode
        self.personNumber = personNumber
        self.contractNumber = contractNumber
        self.authorNumber = authorNumber
    }
    
    static func createCreationStatement(plannedCompletionDate: Date?, taskDetails: String,
                                        priorityCode: Int, taskTypeCode: Int,
                                        personNumber: Int64, contractNumber: Int?,
                                        authorNumber: Int) -> String {
        let creationDate = Date()
        let taskStatus = 0
        var plannedDateExists = false
        if let _ = plannedCompletionDate { plannedDateExists = true }
        var contractNumberExists = false
        if let _ = contractNumber {contractNumberExists = true}
        return "INSERT INTO tasks(creation_date, \(plannedDateExists ? "planned_completion_date,": "") task_status, task_details, priority_code, task_type_code, person_number, \(contractNumberExists ? "contract_number,": "") author_number) VALUES ();"
        
    }
    
    static func createFromRow(row: Result<Row, Error>) throws -> Task {
        let columns = try row.get().columns
        let id = Int64(try columns[0].int())
        let postgresCreationDate = PostgresDate(try columns[1].string())
        let creationDate = postgresCreationDate?.dateComponents.date
        let postgresPlannedCompletionDate = PostgresDate(try columns[2].string())
        let plannedCompletionDate = postgresPlannedCompletionDate?.dateComponents.date
        let postgresActualCompletionDate = PostgresDate(try columns[3].string())
        let actualCompletionDate = postgresActualCompletionDate?.dateComponents.date
        let taskStatus = try columns[4].int()
        let taskDetails = try columns[5].string()
        let priorityCode = try columns[6].int()
        let taskTypeCode = try columns[7].int()
        let personNumber = Int64(try columns[8].int())
        var contractNumber: Int? = nil
        if !columns[9].isNull {
            contractNumber = try columns[9].int()
        }
        let authorNumber = try columns[10].int()
        return Task(id: id, creationDate: creationDate!,
                    plannedVompletionDate: plannedCompletionDate, actualCompletionDate: actualCompletionDate,
                    taskStatus: taskStatus, tasksDetails: taskDetails,
                    priorityCode: priorityCode, taskTypeCode: taskTypeCode,
                    personNumber: personNumber, contractNumber: contractNumber,
                    authorNumber: authorNumber)
    }
}
