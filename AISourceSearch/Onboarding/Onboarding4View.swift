//
//  Onboarding4View.swift
//  OnboardingApp
//
//  Created on 05/11/2025.
//

import SwiftUI
import StoreKit

struct Onboarding4View: View {
    @State private var selectedGoal: SearchGoal = .similarImages
    var onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text("What is your goal?")
                .foregroundStyle(.black)
                .font(.system(size: 32, weight: .semibold))
                .padding(.bottom, 150)
            
            VStack(spacing: 0) {
                ForEach(SearchGoal.allCases, id: \.self) { goal in
                    RadioButton(
                        title: goal.localizedName,
                        isSelected: selectedGoal == goal,
                        action: {
                            selectedGoal = goal
                        }
                    )
                }
            }
            .offset(y: -100)
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Gradient(colors: [Color(hex: "3496FF"), Color(hex: "145AEB")]))
                    .cornerRadius(32)
            }
            .padding(.top, 32)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .onAppear {
            requestRating()
        }
    }
    
    private func requestRating() {
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
}

#Preview {
    Onboarding4View(onContinue: {})
}

