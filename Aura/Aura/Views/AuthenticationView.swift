//
//  AuthenticationView.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

struct AuthenticationView: View {
    
    let gradientStart = Color(hex: "#94A684").opacity(0.7)
    let gradientEnd = Color(hex: "#94A684").opacity(0.0)

    @ObservedObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [gradientStart, gradientEnd]), startPoint: .top, endPoint: .bottomLeading)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Image(systemName: "person.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    
                Text("Welcome !")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading) {
                    TextField("Adresse email", text: $viewModel.username)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                        .onChange(of: viewModel.username) { _ in
                            viewModel.validateEmail()
                        }
                    
                    if !viewModel.isEmailValid {
                        Text("Email invalide")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                SecureField("Mot de passe", text: $viewModel.password)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: {
                    viewModel.login()
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Se connecter")
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .cornerRadius(8)
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal, 40)
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    AuthenticationView(viewModel: AuthenticationViewModel({
    }))
}
