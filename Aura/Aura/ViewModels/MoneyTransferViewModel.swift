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
    
    @MainActor
    func sendMoney() {
        guard validateRecipient() else {
            error = "Please enter a valid email or French phone number"
            return
        }
        
        guard validateAmount(),
              let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            error = "Please enter a valid amount"
            return
        }
        
        isLoading = true
        error = nil
        transferMessage = ""
        
        Task {
            do {
                try await APIService.shared.transferMoney(to: recipient.trimmingCharacters(in: .whitespaces), amount: amountValue)
                self.transferMessage = "Successfully transferred €\(amount) to \(recipient)"
                self.recipient = ""
                self.amount = ""
            } catch {
                self.error = error.localizedDescription
            }
            self.isLoading = false
        }
    }
}
