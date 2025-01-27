//
//  AllTransactionsViewModel.swift
//  Aura
//
//  Created by pascal jesenberger on 22/01/2025.
//

import Foundation

class AllTransactionsViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    struct Transaction: Identifiable {
        let id = UUID()
        let description: String
        let amount: String
        let date: Date
        
        static func from(apiTransaction: AllTransactionsAPITransaction) -> Transaction {
            let sign = apiTransaction.value >= 0 ? "+" : ""
            let formattedAmount = String(format: "%@€%.2f", sign, apiTransaction.value)
            return Transaction(
                description: apiTransaction.label,
                amount: formattedAmount,
                date: Date()
            )
        }
    }
    
    init() {
        fetchTransactions()
    }
    
    func fetchTransactions() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let response = try await APIService.shared.getAllTransactions()
                self.transactions = response.transactions.map { Transaction.from(apiTransaction: $0) }
            } catch {
                self.error = error.localizedDescription
            }
            self.isLoading = false
        }
    }
}
