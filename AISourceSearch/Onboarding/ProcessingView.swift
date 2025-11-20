//
//  ProcessingView.swift
//  OnboardingApp
//
//  Created on 05/11/2025.
//

import SwiftUI

struct ProcessingView: View {
    @State private var isAnimating = false
    @State private var navigateToMain = false
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        Gradient(colors: [Color(hex: "3496FF"), Color(hex: "145AEB")]),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 1)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
            .padding(.bottom, 30)
            
            VStack(spacing: 8) {
                Text("Just a second...")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(hex: "121212").opacity(0.75))
                
                Text("Setting up the search for you")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Color(hex: "121212"))
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onAppear {
            isAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                hasLaunchedBefore = true
                navigateToMain = true
            }
        }
        .fullScreenCover(isPresented: $navigateToMain) {
            MainTabView()
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ProcessingView()
}

