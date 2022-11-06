//
//  ContactPerson.swift
//  printers-company-crm
//
//  Created by George Stykalin on 04.11.2022.
//

import Foundation
import PostgresClientKit

class ContactPerson: Identifiable, RowDerivable {
    typealias DataType = ContactPerson
    
    static let getAllStatementText = "SELECT * FROM contact_persons;"
    
    let id: Int64
    var personName: String
    var personMobileNumber: Int64
    var personEmail: String
    var personMail: String
    var organizationNumber: Int
    
    init(personNumber: Int64, personName: String,
         personMobileNumber: Int64, personEmail: String,
         personMail: String, organizationNumber: Int) {
        self.id = personNumber
        self.personName = personName
        self.personMobileNumber = personMobileNumber
        self.personEmail = personEmail
        self.personMail = personMail
        self.organizationNumber = organizationNumber
    }
    
    static func createGetByOrgNumberStatement(orgNumber: Int) -> String {
        return "SELECT * FROM contact_persons WHERE (organization_number = \(orgNumber));"
    }
    
    static func createCreationStatement(personName: String, personMobile: Int64,
                                        personEmail: String, personMail: String,
                                        organizationNumber: Int) -> String {
        return "INSERT INTO contact_persons(person_name, person_mobile_number,"
                                         + "person_email, person_mail, "
                                         + "organization_number)"
             + " VALUES('\(personName)', \(personMobile), "
                     + "'\(personEmail)', '\(personMail)', \(organizationNumber));"
    }
    
    static func createFromRow(row: Result<Row, Error>) throws -> ContactPerson {
        let columns = try row.get().columns
        let personNumber = Int64(try columns[0].int())
        let personName = try columns[1].string()
        let personMobileNumber = Int64(try columns[2].int())
        let personEmail = try columns[3].string()
        let personMail = try columns[4].string()
        let organizationNumber = try columns[5].int()
        
        return ContactPerson(personNumber: personNumber,
                             personName: personName,
                             personMobileNumber: personMobileNumber,
                             personEmail: personEmail,
                             personMail: personMail,
                             organizationNumber: organizationNumber)
    }
}
