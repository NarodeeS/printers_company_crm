//
//  Contract.swift
//  printers-company-crm
//
//  Created by George Stykalin on 04.11.2022.
//

import Foundation
import PostgresClientKit

class Contract: Identifiable, RowDerivable {
    typealias DataType = Contract
    
    static let getAllStatementText = "SELECT * FROM contracts;"
    
    let id: Int
    let contractDetails: String
    let organizationNumber: Int
    
    init(contractNumber: Int, contractDetails: String, organizationNumber: Int) {
        self.id = contractNumber
        self.contractDetails = contractDetails
        self.organizationNumber = organizationNumber
    }
    
    static func createFromRow(row: Result<Row, Error>) throws -> Contract {
        let columns = try row.get().columns
        let contractNumber = try columns[0].int()
        let contractDetails = try columns[1].string()
        let organizationNumber = try columns[2].int()
        
        return Contract(contractNumber: contractNumber,
                        contractDetails: contractDetails,
                        organizationNumber: organizationNumber)
    }
}
