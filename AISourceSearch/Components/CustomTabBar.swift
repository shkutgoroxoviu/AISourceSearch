//
//  CustomTabBar.swift
//  OnboardingApp
//
//  Created on 06/11/2025.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    var onCameraTap: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            TabButton(
                icon: "house",
                title: "Home",
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }
            
            Spacer()
            
            Button(action: {
                onCameraTap()
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "4A90E2"), Color(hex: "357ABD")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "F4F6F8"), lineWidth: 6)
                        )
                    
                    Image("photoTab")
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            TabButton(
                icon: "clock",
                title: "History",
                isSelected: selectedTab == .history
            ) {
                selectedTab = .history
            }
        }
        .background(
            Color.white
                .cornerRadius(44)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
        .background(Color(hex: "F4F6F8").ignoresSafeArea())
    }
}

struct TabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? "\(icon).fill" : icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(isSelected ? Color(hex: "4A90E2") : .black)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? Color(hex: "4A90E2") : .black)
            }
            .frame(maxWidth: .infinity)
        }
    }
}


