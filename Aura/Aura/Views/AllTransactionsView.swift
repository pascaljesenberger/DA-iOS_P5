//
//  AllTransactionsView.swift
//  Aura
//
//  Created by pascal jesenberger on 22/01/2025.
//

import SwiftUI

struct AllTransactionsView: View {
    @ObservedObject var viewModel: AllTransactionsViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("All Transactions")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.top)
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .padding()
                } else if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.transactions) { transaction in
                            TransactionRow(transaction: transaction)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}
