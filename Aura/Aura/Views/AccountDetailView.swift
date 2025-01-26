//
//  AccountDetailView.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

struct AccountDetailView: View {
    @ObservedObject var viewModel: AccountDetailViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Text("Your Balance")
                        .font(.headline)
                    Text(viewModel.totalAmount)
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(Color(hex: "#94A684"))
                    Image(systemName: "eurosign.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .foregroundColor(Color(hex: "#94A684"))
                }
                .padding(.top)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Transactions")
                        .font(.headline)
                        .padding([.horizontal])
                    ForEach(viewModel.recentTransactions, id: \.description) { transaction in
                        HStack {
                            Image(systemName: transaction.amount.contains("+") ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
                                .foregroundColor(transaction.amount.contains("+") ? .green : .red)
                            Text(transaction.description)
                            Spacer()
                            Text(transaction.amount)
                                .fontWeight(.bold)
                                .foregroundColor(transaction.amount.contains("+") ? .green : .red)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding([.horizontal])
                    }
                }
                
                // Button to see details of transactions
                NavigationLink(destination: AllTransactionsView(viewModel: AllTransactionsViewModel())) {
                    HStack {
                        Image(systemName: "list.bullet")
                        Text("See Transaction Details")
                    }
                    .padding()
                    .background(Color(hex: "#94A684"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding([.horizontal, .bottom])
                
                Spacer()
            }
            .onTapGesture {
                self.endEditing(true)  // This will dismiss the keyboard when tapping outside
            }
        }
    }
}

#Preview {
    AccountDetailView(viewModel: AccountDetailViewModel())
}
