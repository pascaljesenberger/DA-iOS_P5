//
//  AccountDetailModels.swift
//  Aura
//
//  Created by pascal jesenberger on 26/01/2025.
//

import Foundation

struct AccountDetailAPIResponse: Codable {
    let currentBalance: Double
    let transactions: [AccountDetailAPITransaction]
}

struct AccountDetailAPITransaction: Codable {
    let value: Double
    let label: String
}
