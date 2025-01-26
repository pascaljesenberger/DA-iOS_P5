//
//  TransactionRow.swift
//  Aura
//
//  Created by pascal jesenberger on 22/01/2025.
//

import SwiftUI

struct TransactionRow: View {
    let transaction: AllTransactionsViewModel.Transaction
    
    var body: some View {
        HStack {
            Image(systemName: transaction.amount.contains("+") ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
                .foregroundColor(transaction.amount.contains("+") ? Color(hex: "#94A684") : .red)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.system(size: 16, weight: .medium))
                Text(transaction.date, style: .date)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(transaction.amount)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(transaction.amount.contains("+") ? Color(hex: "#94A684") : .red)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
