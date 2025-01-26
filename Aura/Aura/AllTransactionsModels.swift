//
//  AllTransactionsModels.swift
//  Aura
//
//  Created by pascal jesenberger on 26/01/2025.
//

import Foundation

struct AllTransactionsAPIResponse: Codable {
    let currentBalance: Double
    let transactions: [AllTransactionsAPITransaction]
}

struct AllTransactionsAPITransaction: Codable {
    let value: Double
    let label: String
}
