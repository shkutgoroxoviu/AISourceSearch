//
//  HomeContentView.swift
//  BusterAI
//
//  Created by b on 06.11.2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct HomeContentView: View {
    enum ActionSheetType: Identifiable {
        case image
        case file

        var id: Int {
            switch self {
            case .image: return 1
            case .file: return 2
            }
        }
    }
    
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showImagePicker = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var activeActionSheet: ActionSheetType? = nil
    @State private var showSettings = false
    @State private var showSubscriptions = false
    @State private var showFileImporter = false
    @State private var selectedImage: UIImage? = nil
    @State private var capturedPhoto: CapturedPhoto? = nil
    @State private var editPhoto: CapturedPhoto? = nil
    @State private var result: ReverseSearchStatusResponse?
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    showSettings = true
                } label: {
                    Image(.settings)
                }
            }
            .padding(.horizontal, 16)
            VStack(spacing: 8) {
                HomeButton(image: .imageUpload, title: "Upload an image", action: {
                    activeActionSheet = .image
                })
                HomeButton(image: .fileUpload, title: "Upload a file", action: {
                    activeActionSheet = .file
                })
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            Spacer()
        }
        .onAppear {
            Task.detached(priority: .userInitiated) {
                await subscriptionManager.checkSubscriptionStatus()
                await MainActor.run {
                    if !subscriptionManager.isSubscribed {
                        showSubscriptions = true
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "F5F5F5"))
        .actionSheet(item: $activeActionSheet) { type in
            switch type {
            case .image:
                return ActionSheet(title: Text("Select Photo"), buttons: [
                    .default(Text("Photo Library")) {
                        imageSource = .photoLibrary
                        showImagePicker = true
                    },
                    .cancel()
                ])
            case .file:
                return ActionSheet(title: Text("Select File"), buttons: [
                    .default(Text("Files")) {
                        showFileImporter = true
                    },
                    .cancel()
                ])
            }
        }
        .fullScreenCover(isPresented: $showSubscriptions) {
            SubscriptionView()
                .ignoresSafeArea()
        }
        .fullScreenCover(item: $result) { result in
            SearchResultView(searchResult: result)
                .ignoresSafeArea()
        }
        .fullScreenCover(item: $editPhoto) { editPhoto in
            SearchImageView(image: editPhoto.image, sendSearchResult: { result in
                self.result = result
                self.editPhoto = nil
                self.capturedPhoto = nil
            })
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
                .ignoresSafeArea()
        }
        .fullScreenCover(item: $capturedPhoto) { photo in
            PhotoEditorView(image: .constant(photo.image), sendPhoto: { image in
                editPhoto = CapturedPhoto(image: image)
            })
        }
        .fullScreenCover(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: imageSource, onCapture: { image in
                capturedPhoto = CapturedPhoto(image: image)
            })
            .ignoresSafeArea()
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let url = try result.get().first else { return }

                var image: UIImage? = nil

                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() }
                    if let data = try? Data(contentsOf: url) {
                        image = UIImage(data: data)
                    }
                } else {
                    if let data = try? Data(contentsOf: url) {
                        image = UIImage(data: data)
                    }
                }

                if let image = image {
                    capturedPhoto = CapturedPhoto(image: image)
                }
            } catch {
                print("Failed to load file: \(error)")
            }
        }

    }
}

struct HomeButton: View {
    var image: ImageResource
    var title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                Image(image)
                    .padding(.leading, 16)
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                Spacer()
            }
        }
        .frame(height: 56)
        .background(.white)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .cornerRadius(15)
    }
}
