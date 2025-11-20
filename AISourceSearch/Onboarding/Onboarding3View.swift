//
//  Onboarding3View.swift
//  OnboardingApp
//
//  Created on 05/11/2025.
//

import SwiftUI

struct Onboarding3View: View {
    @State private var selectedSource: SearchSource = .camera
    var onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text("Where do you want to\nstart the search from?")
                .foregroundStyle(.black)
                .font(.system(size: 32, weight: .semibold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.bottom, 150)
            
            VStack(spacing: 0) {
                ForEach(SearchSource.allCases, id: \.self) { source in
                    RadioButton(
                        title: source.localizedName,
                        isSelected: selectedSource == source,
                        action: {
                            selectedSource = source
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
    }
}

struct RadioButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(.white)
            .cornerRadius(15)
        }
        .padding(.bottom, 12)
    }
}

#Preview {
    Onboarding3View(onContinue: {})
}

