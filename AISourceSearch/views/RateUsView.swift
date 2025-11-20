//
//  RateUsView.swift
//  AISourceSearch
//
//  Created by b on 20.11.2025.
//

import SwiftUI
import StoreKit

struct RateUsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showAppStoreFallback = false
    
    var body: some View {
        ZStack {
            Color(hex: "F4F6F8")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                Image(.heart)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                
                Text("Enjoying Buster AI?")
                    .font(.system(size: 20).bold())
                    .foregroundColor(.black)
                
                Text("Your feedback helps us grow and make the app even smarter.")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
                HStack(spacing: 16) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Rate it later")
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.white)
                            .cornerRadius(32)
                            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
                    }
                    Button(action: {
                        requestRating()
                    }) {
                        Text("Rate now")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "3496FF"), Color(hex: "145AEB")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(32)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .padding()
        .background(Color(hex: "F4F6F8"))
        .ignoresSafeArea()
    }
    
    private func requestRating() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
