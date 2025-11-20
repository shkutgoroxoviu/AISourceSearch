//
//  SettingsView.swift
//  BusterAI
//
//  Created by b on 13.11.2025.
//


import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showSubscription = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isRestoring = false
    @State private var showShareSheet = false
    @State private var showRate = false
    
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(hex: "121212").opacity(0.8))
                        .padding(10) 
                        .background(Color.white)
                        .clipShape(Circle())                }

                Spacer()

                Text("Settings")
                    .foregroundColor(.black)
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .offset(x: -10)

                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 60)

            // MARK: - Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    VStack(spacing: 0) {
                        Button {
                            if subscriptionManager.isSubscribed {
                                alertMessage = "You already have an active subscription"
                                showAlert = true
                            } else {
                                showSubscription = true
                            }
                        } label: {
                            SettingsRow(
                                icon: .getPremiumIcon,
                                iconColor: .yellow,
                                title: "Get Premium",
                                showChevron: true
                            )
                        }

                        Divider().padding(.leading, 44)
                        Button {
                            restorePurchases()
                        } label: {
                            SettingsRow(
                                icon: .restoreIcon,
                                iconColor: .blue,
                                title: isRestoring ? "Restoring..." : "Restore purchases",
                                showChevron: true
                            )
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    VStack(spacing: 0) {
                        Button {
                            openURL("https://docs.google.com/forms/d/e/1FAIpQLSdfzYEUL_CB3y1GT_wAoJCLHclor-3YNcvhwmQ8UirR96qDkA/viewform?usp=publish-editor")
                        } label: {
                            SettingsRow(
                                icon: .supportIcon,
                                iconColor: .green,
                                title: "Support",
                                showChevron: true
                            )
                        }
                        Divider().padding(.leading, 44)
                        Button {
                            openURL("https://docs.google.com/document/d/1EawiOaouhDCNeyW5M_i8Oac6u3jCVZTr9nhpepVDTW4/edit?usp=sharing")
                        } label: {
                            SettingsRow(
                                icon: .termsIcon,
                                iconColor: .gray,
                                title: "Terms of Use",
                                showChevron: true
                            )
                        }

                        Divider().padding(.leading, 44)
                        Button {
                            openURL("https://docs.google.com/document/d/1EKSY5Cg5g8qeFV8v67lw_sRD_9GRGAQGYrx7bZzZYCM/edit?usp=sharing")
                        } label: {
                            SettingsRow(
                                icon: .privacyIcon,
                                iconColor: .gray,
                                title: "Privacy Policy",
                                showChevron: true
                            )
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)

                    VStack(spacing: 0) {
                        Button {
                            showRate = true
                        } label: {
                            SettingsRow(
                                icon: .rateIcon,
                                iconColor: .orange,
                                title: "Rate Us",
                                showChevron: true
                            )
                        }

                        Divider().padding(.leading, 44)
                        Button {
                            showShareSheet = true
                        } label: {
                            SettingsRow(
                                icon: .shareIcon,
                                iconColor: .blue,
                                title: "Share with friends",
                                showChevron: true
                            )
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .fullScreenCover(isPresented: $showRate, content: {
            RateUsView()
                .ignoresSafeArea()
        })
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: ["Check out AI Source Search! https://apps.apple.com/us/app/ai-source-search/id6755436033"])
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Subscription"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: $showSubscription, content: {
            SubscriptionView()
                .ignoresSafeArea()
        })
        .background(Color(hex: "F5F5F5").ignoresSafeArea())
    }
    
    private func restorePurchases() {
        isRestoring = true
        subscriptionManager.restorePurchases { success, message in
            isRestoring = false
            alertMessage = message ?? (success ? "Subscription restored successfully" : "Couldn't restore subscription")
            showAlert = true
        }
    }
    
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

struct SettingsRow: View {
    let icon: ImageResource
    let iconColor: Color
    let title: String
    let showChevron: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(icon)
                .frame(width: 24, height: 24)

            Text(title)
                .foregroundColor(.black)
                .font(.body)

            Spacer()

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - ShareSheet Wrapper
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
