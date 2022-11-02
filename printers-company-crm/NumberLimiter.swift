//
//  TextLimiter.swift
//  printers-company-crm
//
//  Created by George Stykalin on 02.11.2022.
//

import Foundation

class NumberLimiter: ObservableObject {
    private let limit: Int
    
    init(limit: Int) {
        self.limit = limit
    }
    
    @Published var value: Int64 = 8 {
        didSet {
            let stringifiedNumber = String(value)
            if stringifiedNumber.count > limit {
                value = Int64(String(stringifiedNumber.prefix(limit))) ?? 8
            }
        }
    }
}
