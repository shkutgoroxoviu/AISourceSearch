//
//  SubscriptionView.swift
//  BusterAI
//
//  Created by b on 13.11.2025.
//

import SwiftUI
import ApphudSDK
import StoreKit

// MARK: - Subscription View (Apphud)
struct SubscriptionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedPlan: PlanType = .annual
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var storeKitSubscriptionManager = StoreKitSubscriptionManager.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                Image(.subBackground)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: 600)
                    .ignoresSafeArea(edges: .top)
                Spacer()
            }
            
            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(hex: "121212").opacity(0.8))
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 60)
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 16) {
                    // MARK: - Annual Plan
                    if let annualProduct = subscriptionManager.products.first(where: { $0.productId.contains("year") }) {
                        ZStack(alignment: .topTrailing) {
                            SubscriptionPlanCard(
                                title: "Annual rate",
                                subtitle: subscriptionManager.getPriceString(for: annualProduct) + " / year",
                                details: String(format: "$%.1f / week", subscriptionManager.getPriceValue(for: annualProduct) / 52),
                                isSelected: selectedPlan == .annual
                            )
                            .onTapGesture { selectedPlan = .annual }
                            
                            Text("50%")
                                .padding(.horizontal, 16)
                                .padding(.vertical, 3)
                                .background(Color(hex: "20C33E"))
                                .foregroundStyle(.white)
                                .cornerRadius(15)
                                .offset(x: -20, y: -15)
                        }
                    }
                    
                    // MARK: - Weekly Plan
                    if let weeklyProduct = subscriptionManager.products.first(where: { $0.productId.contains("week") }) {
                        SubscriptionPlanCard(
                            title: "Weekly rate",
                            subtitle: subscriptionManager.getPriceString(for: weeklyProduct) + " / week",
                            details: String(format: "$%.1f / day", subscriptionManager.getPriceValue(for: weeklyProduct) / 7),
                            isSelected: selectedPlan == .weekly
                        )
                        .onTapGesture { selectedPlan = .weekly }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                .background(Color(hex: "F5F5F5"))
                .clipShape(RoundedCorners(radius: 44, corners: [.topLeft, .topRight]))
                
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        Link("Privacy Policy", destination: URL(string: "https://docs.google.com/document/d/1EKSY5Cg5g8qeFV8v67lw_sRD_9GRGAQGYrx7bZzZYCM/edit?usp=sharing")!)
                        Link("Terms of Use", destination: URL(string: "https://docs.google.com/document/d/1EawiOaouhDCNeyW5M_i8Oac6u3jCVZTr9nhpepVDTW4/edit?usp=sharing")!)
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
                
                // MARK: - Purchase Button
                Button(action: purchaseSelectedPlan) {
                    Text(buttonTitle)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "3496FF"), Color(hex: "145AEB")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(32)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
                
            }
        }
        .onAppear(perform: {
            subscriptionManager.loadProducts()
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "F5F5F5"))
        .ignoresSafeArea()
    }
    
    // MARK: - Button Title
    private var buttonTitle: String {
        subscriptionManager.isSubscribed ? "Subscribed" : "Continue"
    }
    
    // MARK: - Selected Product
    private func selectedProduct() -> ApphudProduct? {
        switch selectedPlan {
        case .annual:
            return subscriptionManager.products.first(where: { $0.productId.contains("year") })
        case .weekly:
            return subscriptionManager.products.first(where: { $0.productId.contains("week") })
        }
    }
    
    // MARK: - Purchase Action
    private func purchaseSelectedPlan() {
        guard let product = selectedProduct() else { return }
        subscriptionManager.purchase(product: product) { success, error in
            if let error = error {
                print("❌ Purchase error: \(error)")
            } else {
                dismiss()
                print("✅ Purchase success: \(success)")
            }
        }
    }
    
    private func storeSelectedProduct() -> Product? {
        switch selectedPlan {
        case .annual:
            return storeKitSubscriptionManager.products.first(where: { $0.id.contains("year") })
        case .weekly:
            return storeKitSubscriptionManager.products.first(where: { $0.id.contains("week") })
        }
    }
    
    private func purchaseSelected() {
        guard let product = storeSelectedProduct() else { return }
        Task { await storeKitSubscriptionManager.purchase(product, completion: { isSuccess, _ in
            if isSuccess {
                dismiss()
            }
        })}
    }
}

// MARK: - Plan Type
enum PlanType {
    case annual, weekly
}

// MARK: - Subscription Plan Card
struct SubscriptionPlanCard: View {
    let title: String
    let subtitle: String
    let details: String
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
            Spacer()
            Text(details)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? Color(hex: "E8F0FF") : Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color(hex: "3496FF") : Color(hex: "E0E0E0"), lineWidth: 2)
        )
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

