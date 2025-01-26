//
//  MoneyTransferViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class MoneyTransferViewModel: ObservableObject {
    @Published var recipient: String = ""
    @Published var amount: String = ""
    @Published var transferMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var isRecipientValid: Bool = true
    @Published var isAmountValid: Bool = true
    
    private let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    private let frenchPhoneRegex = "^(\\+33|0)[1-9](\\d{2}){4}$"
    
    func validateRecipient() -> Bool {
        let recipient = self.recipient.trimmingCharacters(in: .whitespaces)
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        let isValidEmail = emailPred.evaluate(with: recipient)
        
        let phonePred = NSPredicate(format: "SELF MATCHES %@", frenchPhoneRegex)
        let cleanedPhone = recipient.replacingOccurrences(of: " ", with: "")
        let isValidPhone = phonePred.evaluate(with: cleanedPhone)
        
        isRecipientValid = isValidEmail || isValidPhone
        return isRecipientValid
    }
    
    func validateAmount() -> Bool {
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            isAmountValid = false
            return false
        }
        
        isAmountValid = amountValue > 0
        return isAmountValid
    }
    
    func sendMoney() {
        guard validateRecipient() else {
            error = "Please enter a valid email or French phone number"
            return
        }
        
        guard validateAmount() else {
            error = "Please enter a valid amount"
            return
        }
        
        isLoading = true
        error = nil
        transferMessage = ""
        
        guard let url = URL(string: "http://127.0.0.1:8080/account/transfer"),
              let token = UserDefaults.standard.string(forKey: "authToken"),
              let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            isLoading = false
            error = "Invalid request data"
            return
        }
        
        let body = [
            "recipient": recipient.trimmingCharacters(in: .whitespaces),
            "amount": amountValue
        ] as [String: Any]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "token")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            self.isLoading = false
            self.error = "Error preparing request"
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = error.localizedDescription
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.error = "Invalid response"
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    self?.transferMessage = "Successfully transferred €\(self?.amount ?? "") to \(self?.recipient ?? "")"
                    self?.recipient = ""
                    self?.amount = ""
                } else {
                    self?.error = "Transfer failed with status code: \(httpResponse.statusCode)"
                }
            }
        }.resume()
    }
}
