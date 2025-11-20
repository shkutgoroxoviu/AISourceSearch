//
//  MainTabView.swift
//  BusterAI
//
//  Created by b on 06.11.2025.
//
import SwiftUI
import UIKit

enum TabItem {
    case home
    case camera
    case history
}

struct CapturedPhoto: Identifiable {
    let id = UUID()
    var image: UIImage
}

struct MainTabView: View {
    @State private var selectedTab: TabItem = .home
    @State private var isShowingCamera = false
    @State private var isShowingSearch = false
    @State private var capturedPhoto: CapturedPhoto? = nil
    @State private var editPhoto: CapturedPhoto? = nil
    @State private var result: ReverseSearchStatusResponse?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeContentView()
                case .camera:
                    HomeContentView()
                case .history:
                    HistoryContentView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            CustomTabBar(selectedTab: $selectedTab, onCameraTap: { openCamera() })
        }
        .fullScreenCover(item: $capturedPhoto) { photo in
            PhotoEditorView(image: .constant(photo.image), sendPhoto: { image in
                editPhoto = CapturedPhoto(image: image)
                capturedPhoto = nil
            })
        }
        .fullScreenCover(item: $editPhoto) { editPhoto in
            SearchImageView(image: editPhoto.image, sendSearchResult: { result in
                self.result = result
                self.editPhoto = nil
            })
            .ignoresSafeArea()
        }
        .fullScreenCover(item: $result) { result in
            SearchResultView(searchResult: result)
                .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            CameraView { image in
                capturedPhoto = CapturedPhoto(image: image)
                isShowingCamera = false
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea(.keyboard)
    }

    private func openCamera() {
        if !isShowingCamera {
            isShowingCamera = true
        }
    }
}


