//
//  RowDerivable.swift
//  printers-company-crm
//
//  Created by George Stykalin on 05.11.2022.
//

import Foundation
import PostgresClientKit


protocol RowDerivable {
    associatedtype DataType
    static func createFromRow(row: Result<Row, any Error>) throws -> DataType
}
