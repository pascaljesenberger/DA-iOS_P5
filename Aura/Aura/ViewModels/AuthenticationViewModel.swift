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
    
    @MainActor
    func login() {
        validateEmail()
        guard isEmailValid else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                let response = try await APIService.shared.authenticate(username: username, password: password)
                self.token = response.token
                UserDefaults.standard.set(response.token, forKey: "authToken") // garde le token dans UserDefaults
                self.onLoginSucceed()
            } catch {
                self.error = "Une erreur s'est produite. Veuillez réessayer plus tard."
            }
            self.isLoading = false
        }
    }
}
