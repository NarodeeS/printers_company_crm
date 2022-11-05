//
//  Organization.swift
//  printers-company-crm
//
//  Created by George Stykalin on 04.11.2022.
//

import Foundation
import PostgresClientKit

class Organization: Identifiable, RowDerivable {
    enum OrganizationStatus: String, CaseIterable {
        case active = "Active"
        case potential = "Potential"
    }
    
    typealias DataType = Organization
    
    static let getAllStatementText = "SELECT * FROM organizations;"
    
    let id: Int
    let organizationName: String
    let organizationEmail: String
    let organizationMail: String
    let organizationCity: String
    let organizationStatus: OrganizationStatus
    
    init(organizationNumber: Int, organizationName: String,
         organizationEmail: String, organizationMail: String,
         organizationCity: String, organizationStatus: OrganizationStatus) {
        self.id = organizationNumber
        self.organizationName = organizationName
        self.organizationEmail = organizationEmail
        self.organizationMail = organizationMail
        self.organizationCity = organizationCity
        self.organizationStatus = organizationStatus
    }
    
    static func getCreateStatementText(organizationName: String,
                                       organizationEmail: String,
                                       organizationMail: String,
                                       organizationCity: String,
                                       organizationStatus: OrganizationStatus) -> String {
        return "INSERT INTO organizations(organization_name, "
                                       + "organization_email, organization_mail,"
                                       + "organization_city, client_type)"
             + " VALUES ('\(organizationName)', '\(organizationEmail)',"
                     + "'\(organizationMail)',"
                     + "'\(organizationCity)',"
                     + "\(OrganizationStatus.allCases.firstIndex(of: organizationStatus)!));"
    }
    
    static func createFromRow(row: Result<Row, Error>) throws -> Organization {
        let columns = try row.get().columns
        let organizationNumber = try columns[0].int()
        let organizationName = try columns[1].string()
        let organizationEmail = try columns[2].string()
        let organizationMail = try columns[3].string()
        let organizationCity = try columns[4].string()
        let organizationStatusCode = try columns[5].int()
        
        var organizationStatus = OrganizationStatus.potential
        
        switch organizationStatusCode {
        case 0:
            organizationStatus = .active
        default:
            organizationStatus = .potential
        }
        
        return Organization(organizationNumber: organizationNumber,
                            organizationName: organizationName,
                            organizationEmail: organizationEmail,
                            organizationMail: organizationMail,
                            organizationCity: organizationCity,
                            organizationStatus: organizationStatus)
    }
}
