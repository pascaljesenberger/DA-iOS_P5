//
//  AccountDetailViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AccountDetailViewModel: ObservableObject {
    @Published var totalAmount: String = "€0.00"
    @Published var recentTransactions: [Transaction] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    struct Transaction: Identifiable {
        let id = UUID()
        let description: String
        let amount: String
        
        static func from(apiTransaction: AccountDetailAPITransaction) -> Transaction {
            let sign = apiTransaction.value >= 0 ? "+" : ""
            let formattedAmount = String(format: "%@€%.2f", sign, apiTransaction.value)
            return Transaction(description: apiTransaction.label, amount: formattedAmount)
        }
    }
    
    init() {
        fetchAccountDetails()
    }
    
    func fetchAccountDetails() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let response = try await APIService.shared.getAccountDetails()
                let formattedTotal = String(format: "€%.2f", response.currentBalance)
                let limitedTransactions = response.transactions.prefix(3)
                let mappedTransactions = limitedTransactions.map { Transaction.from(apiTransaction: $0) }
                
                await MainActor.run {
                    self.totalAmount = formattedTotal
                    self.recentTransactions = mappedTransactions
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
