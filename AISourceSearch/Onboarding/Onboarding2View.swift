//
//  Onboarding2View.swift
//  OnboardingApp
//
//  Created on 05/11/2025.
//

import SwiftUI

struct Onboarding2View: View {
    var onContinue: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                HStack {
                    Image(.photoIcon)
                    Text("gerl.img")
                        .font(.system(size: 16))
                        .foregroundStyle(.black)
                }
                .padding(.vertical, 8)
                .padding(.leading, 8)
                Spacer()
                Image(.search)
                    .padding(.trailing, 8)
            }
            .background(.white)
            .cornerRadius(40)
            .padding(.horizontal, 16)
            HStack {
                VStack {
                    Image(.bingIcon)
                    Text("Bing")
                        .font(.system(size: 20))
                        .foregroundStyle(.black)
                }
                .frame(width: 160, height: 160)
                .background(.white)
                .cornerRadius(24)
                VStack {
                    Image(.gptIcon)
                    Text("ChatGPT")
                        .font(.system(size: 20))
                        .foregroundStyle(.black)
                }
                .frame(width: 160, height: 160)
                .background(.white)
                .cornerRadius(24)
            }
            HStack {
                VStack {
                    Image(.googleIcon)
                    Text("Google")
                        .font(.system(size: 20))
                        .foregroundStyle(.black)
                }
                .frame(width: 160, height: 160)
                .background(.white)
                .cornerRadius(24)
                VStack {
                    Image(.yandexIcon)
                    Text("Yandex")
                        .font(.system(size: 20))
                        .foregroundStyle(.black)
                }
                .frame(width: 160, height: 160)
                .background(.white)
                .cornerRadius(24)
            }
            Spacer()
            VStack {
                Text("One query — all the results.")
                    .foregroundStyle(.black)
                    .font(.system(size: 22, weight: .semibold))
                    .padding(.bottom, 8)
                    .padding(.top, 32)
                
                Text("Search in all the leading search engines at once.")
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
            .offset(y: 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    Onboarding2View(onContinue: {})
}

