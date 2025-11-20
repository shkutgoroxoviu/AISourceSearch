//
//  SearchView.swift
//  BusterAI
//
//  Created by b on 13.11.2025.
//

import SwiftUI

struct SearchImageView: View {
    @Environment(\.dismiss) var dismiss
    let image: UIImage
    @State private var taskId: String?
    @State private var progress: CGFloat = 0
    @State private var statusText: String = "Waiting"
    @State private var isProcessing = false
    @State private var result: ReverseSearchStatusResponse?
    @State private var timer: Timer?
    @State private var showResult = false
    var sendSearchResult: ((ReverseSearchStatusResponse?) -> Void)
    
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showSubscribeView = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                }
                Spacer()
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width - 32, height: 300)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .shadow(radius: 5)
                Text("Search")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                    .bold()
                Text(statusText)
                    .foregroundColor(.white)
                    .font(.title2)
                    .bold()
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 8)
                        .foregroundColor(Color(hex: "F5F5F5"))
                    
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: progress * UIScreen.main.bounds.width * 0.9, height: 8)
                        .foregroundColor(Color(hex: "3496FF"))
                        .animation(.linear, value: progress)
                }
                .padding(.horizontal, 20)
                
                Button(action: checkSubscriptionAndStartSearch) {
                    Text("Search")
                        .foregroundColor(isProcessing ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            Group {
                                if isProcessing {
                                    LinearGradient(
                                        colors: [Color(hex: "F5F5F5"), Color(hex: "F3F3F3")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                } else {
                                    LinearGradient(
                                        colors: [Color(hex: "3496FF"), Color(hex: "145AEB")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                }
                            }
                        )
                        .cornerRadius(32)
                        .opacity(isProcessing ? 0.7 : 1.0)
                        .scaleEffect(isProcessing ? 0.98 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isProcessing)
                }
                .disabled(isProcessing)
                .padding(.horizontal, 20)
                .padding(.top, 40)

                Spacer()
            }
            .padding(.top, 100)
        }
        .fullScreenCover(isPresented: $showSubscribeView) {
            SubscriptionView()
                .ignoresSafeArea()
        }
    }
    
    func checkSubscriptionAndStartSearch() {
        if subscriptionManager.isSubscribed {
            startSearch()
        } else {
            showSubscribeView = true
        }
    }
    
    func startSearch() {
        isProcessing = true
        progress = 0
        statusText = "Uploading..."
        
        ReverseSearchAPI.shared.createSearchTask(image: image) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let id):
                    taskId = id
                    statusText = "Processing..."
                    startPolling()
                case .failure(let error):
                    statusText = "Error: \(error.localizedDescription)"
                    isProcessing = false
                }
            }
        }
    }
    
    func startPolling() {
        guard let id = taskId else { return }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            ReverseSearchAPI.shared.getSearchStatus(taskId: id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        let engines = ["google", "yandex", "bing"]
                        let completed = [
                            response.status?.google,
                            response.status?.yandex,
                            response.status?.bing
                        ].filter { $0 == "completed" }.count

                        progress = CGFloat(completed) / CGFloat(engines.count)
                        
                        if completed == engines.count {
                            statusText = "Completed"
                            isProcessing = false
                            self.result = response
                            t.invalidate()
                            HistoryManager.shared.saveHistory(image: image, result: response)
                            sendSearchResult(response)
                            dismiss()
                        }
                    case .failure(let error):
                        statusText = "Error: \(error.localizedDescription)"
                        isProcessing = false
                        t.invalidate()
                        sendSearchResult(nil)
                        dismiss()
                    }
                }
            }
        }
    }
}

