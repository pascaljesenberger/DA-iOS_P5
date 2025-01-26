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
        
        guard let token = UserDefaults.standard.string(forKey: "authToken"),
              let url = URL(string: "http://127.0.0.1:8080/account") else {
            error = "Authentication error"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "token")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self?.error = "No data received"
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(AccountDetailAPIResponse.self, from: data)
                    
                    self?.totalAmount = String(format: "€%.2f", response.currentBalance)
                    
                    let limitedTransactions = response.transactions.prefix(3)
                    self?.recentTransactions = limitedTransactions.map { Transaction.from(apiTransaction: $0) }
                    
                } catch {
                    self?.error = "Invalid response"
                }
            }
        }.resume()
    }
}
