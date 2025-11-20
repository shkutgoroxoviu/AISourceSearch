//
//  CustomPageControl.swift
//  OnboardingApp
//
//  Created on 05/11/2025.
//

import SwiftUI

struct CustomPageControl: View {
    let numberOfPages: Int
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.black : Color.gray.opacity(0.3))
                    .frame(width: index == currentPage ? 32 : 8, height: 4)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomPageControl(numberOfPages: 4, currentPage: 0)
        CustomPageControl(numberOfPages: 4, currentPage: 1)
        CustomPageControl(numberOfPages: 4, currentPage: 2)
        CustomPageControl(numberOfPages: 4, currentPage: 3)
    }
    .padding()
}

