//
//  AuthenticationViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AuthenticationViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isEmailValid: Bool = true
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    private var token: String?
    
    let onLoginSucceed: (() -> ())
    
    init(_ callback: @escaping () -> ()) {
        self.onLoginSucceed = callback
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func validateEmail() {
        isEmailValid = isValidEmail(username)
    }
    
    func login() {
        validateEmail()
        guard isEmailValid else { return }
        
        isLoading = true
        error = nil
        
        guard let url = URL(string: "http://127.0.0.1:8080/auth") else { return }
        
        let body = ["username": username, "password": password]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
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
                    let response = try JSONDecoder().decode(AuthResponse.self, from: data)
                    self?.token = response.token
                    UserDefaults.standard.set(response.token, forKey: "authToken")
                    self?.onLoginSucceed()
                } catch {
                    self?.error = "Invalid response"
                }
            }
        }.resume()
    }
}

struct AuthResponse: Codable {
    let token: String
}
