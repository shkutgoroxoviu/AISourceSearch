//
//  OnboardingContainerView.swift
//  OnboardingApp
//
//  Created on 05/11/2025.
//

import SwiftUI

struct OnboardingContainerView: View {
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    @State private var currentPage = 0
    @State private var showProcessing = false
    
    var body: some View {
        ZStack {
            if !showProcessing {
                ZStack(alignment: .top) {
                    TabView(selection: $currentPage) {
                        Onboarding1View(onContinue: {
                            withAnimation {
                                currentPage = 1
                            }
                        })
                        .tag(0)
                        
                        Onboarding2View(onContinue: {
                            withAnimation {
                                currentPage = 2
                            }
                        })
                        .tag(1)
                        
                        Onboarding3View(onContinue: {
                            withAnimation {
                                currentPage = 3
                            }
                        })
                        .tag(2)
                        
                        Onboarding4View(onContinue: {
                            withAnimation {
                                hasLaunchedBefore = true
                                showProcessing = true
                            }
                        })
                        .tag(3)
                    }
                    .ignoresSafeArea()
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    CustomPageControl(numberOfPages: 4, currentPage: currentPage)
                        .padding(.top, 16)
                }
                .background(Color(hex: "F4F6F8"))
            } else {
                ProcessingView()
                    .background(Color(hex: "F4F6F8"))
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .statusBar(hidden: false)
    }
}

#Preview {
    OnboardingContainerView()
}

