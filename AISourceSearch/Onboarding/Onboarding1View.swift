//
//  Onboarding1View.swift
//  OnboardingApp
//
//  Created on 05/11/2025.
//

import SwiftUI

struct Onboarding1View: View {
    var onContinue: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image("onboardPhoto")
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
            
            VStack {
                Text("Smart photo search")
                    .foregroundStyle(.black)
                    .font(.system(size: 22, weight: .semibold))
                    .padding(.bottom, 8)
                    .padding(.top, 32)
                
                Text("Find people and objects using AI\nrecognition.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
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
                .padding(.bottom, 40)
            }
            .frame(height: 255)
            .background(Color.white)
            .cornerRadius(44)
            .offset(y: 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    Onboarding1View(onContinue: {})
}

