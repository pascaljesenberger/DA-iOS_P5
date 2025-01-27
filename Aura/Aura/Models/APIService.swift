//
//  APIService.swift
//  Aura
//
//  Created by pascal jesenberger on 27/01/2025.
//

import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "http://127.0.0.1:8080"
    
    func authenticate(username: String, password: String) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/auth")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["username": username, "password": password]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }
    
    func getAccountDetails() async throws -> AccountDetailAPIResponse {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            throw APIError.noToken
        }
        
        let url = URL(string: "\(baseURL)/account")!
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "token")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(AccountDetailAPIResponse.self, from: data)
    }
    
    func transferMoney(to recipient: String, amount: Double) async throws {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            throw APIError.noToken
        }
        
        let url = URL(string: "\(baseURL)/account/transfer")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "token")
        
        let body = ["recipient": recipient, "amount": amount] as [String: Any]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.transferFailed
        }
    }
    
    func getAllTransactions() async throws -> AllTransactionsAPIResponse {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            throw APIError.noToken
        }
        
        let url = URL(string: "\(baseURL)/account")!
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "token")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(AllTransactionsAPIResponse.self, from: data)
    }
}

enum APIError: Error {
    case noToken
    case transferFailed
    case invalidResponse
    
    var localizedDescription: String {
        switch self {
        case .noToken:
            return "Authentication error: No token found"
        case .transferFailed:
            return "Transfer failed"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
}
