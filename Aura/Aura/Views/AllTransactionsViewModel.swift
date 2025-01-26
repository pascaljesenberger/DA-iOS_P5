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
        
        static func from(apiTransaction: APITransaction) -> Transaction {
            let sign = apiTransaction.value >= 0 ? "+" : ""
            let formattedAmount = String(format: "%@€%.2f", sign, apiTransaction.value)
            return Transaction(
                description: apiTransaction.label,
                amount: formattedAmount,
                date: Date() // Dans une vraie app, on récupérerait la date de l'API
            )
        }
    }
    
    struct APITransaction: Codable {
        let value: Double
        let label: String
    }
    
    struct APIResponse: Codable {
        let currentBalance: Double
        let transactions: [APITransaction]
    }
    
    init() {
        fetchTransactions()
    }
    
    func fetchTransactions() {
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
                    let response = try JSONDecoder().decode(APIResponse.self, from: data)
                    self?.transactions = response.transactions.map { Transaction.from(apiTransaction: $0) }
                } catch {
                    self?.error = "Invalid response"
                }
            }
        }.resume()
    }
}
