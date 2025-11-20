//
//  PhotoEditor.swift
//  BusterAI
//
//  Created by b on 13.11.2025.
//

import SwiftUI

struct PhotoEditorView: View {
    @Binding var image: UIImage
    @Environment(\.dismiss) var dismiss
    @State var showSearchView: Bool = false
    @State private var rotation: Angle = .zero
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    var sendPhoto: ((UIImage) -> Void)
    
    @State private var isCropping = false
    @State private var cropRect: CGRect = .zero
    @State private var cropOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
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
                
                GeometryReader { geo in
                    ZStack {
                        let imageFrame = calculateImageFrame(in: geo.size)
                        
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .rotationEffect(rotation)
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in offset = value.translation }
                                    .onEnded { _ in
                                        withAnimation(.spring()) { offset = .zero }
                                    }
                            )
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { scale = $0 }
                                    .onEnded { _ in
                                        withAnimation(.spring()) { scale = 1.0 }
                                    }
                            )
                            .gesture(
                                RotationGesture()
                                    .onChanged { rotation = $0 }
                                    .onEnded { _ in
                                        withAnimation(.spring()) { rotation = .zero }
                                    }
                            )
                            .frame(width: geo.size.width, height: geo.size.height)
                            .onAppear { cropRect = imageFrame }
                        
                        if isCropping {
                            CropOverlayView(cropRect: $cropRect, parentSize: imageFrame.size, cropOffset: $cropOffset)
                                .position(x: imageFrame.midX + cropOffset.width, y: imageFrame.midY + cropOffset.height)
                        }
                    }
                }
                
                Spacer()
                
                HStack(spacing: 40) {
                    Button(action: { rotation += .degrees(90) }) {
                        Image(.rotateButton)
                    }
                    Button(action: { isCropping.toggle() }) {
                        Image(.cropButton)
                    }
                    Button(action: { cropImage() }) {
                        Image(.enterButton)
                    }
                }
                .font(.system(size: 24))
                .foregroundColor(.white)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func calculateImageFrame(in parentSize: CGSize) -> CGRect {
        let imageAspect = image.size.width / image.size.height
        let parentAspect = parentSize.width / parentSize.height
        
        var width: CGFloat
        var height: CGFloat
        
        if imageAspect > parentAspect {
            width = parentSize.width
            height = width / imageAspect
        } else {
            height = parentSize.height
            width = height * imageAspect
        }
        
        let x = (parentSize.width - width) / 2
        let y = (parentSize.height - height) / 2
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func cropImage() {
        sendPhoto(image)
    }
}

struct CropOverlayView: View {
    @Binding var cropRect: CGRect
    let parentSize: CGSize
    @Binding var cropOffset: CGSize
    
    let handleSize: CGFloat = 30
    @State private var dragOffset: CGSize = .zero
    @State private var activeCorner: Corner?
    
    enum Corner { case topLeft, topRight, bottomLeft, bottomRight }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .mask(
                    Rectangle()
                        .fill(style: FillStyle())
                        .overlay(
                            Rectangle()
                                .frame(width: cropRect.width, height: cropRect.height)
                                .blendMode(.destinationOut)
                        )
                )
            
            Rectangle()
                .stroke(Color(hex: "3496FF"), lineWidth: 2)
                .frame(width: cropRect.width, height: cropRect.height)
            
            cornerHandle(.topLeft)
                .position(x: 0, y: 0)
            cornerHandle(.topRight)
                .position(x: cropRect.width, y: 0)
            cornerHandle(.bottomLeft)
                .position(x: 0, y: cropRect.height)
            cornerHandle(.bottomRight)
                .position(x: cropRect.width, y: cropRect.height)
        }
        .frame(width: cropRect.width, height: cropRect.height)
        .gesture(
            DragGesture()
                .onChanged { value in
                    cropOffset.width += value.translation.width
                    cropOffset.height += value.translation.height
                }
        )
    }
    
    @ViewBuilder
    private func cornerHandle(_ corner: Corner) -> some View {
        Circle()
            .fill(Color(hex: "3496FF"))
            .frame(width: handleSize, height: handleSize)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        switch corner {
                        case .topLeft:
                            cropRect.origin.x += value.translation.width
                            cropRect.origin.y += value.translation.height
                            cropRect.size.width -= value.translation.width
                            cropRect.size.height -= value.translation.height
                        case .topRight:
                            cropRect.origin.y += value.translation.height
                            cropRect.size.width += value.translation.width
                            cropRect.size.height -= value.translation.height
                        case .bottomLeft:
                            cropRect.origin.x += value.translation.width
                            cropRect.size.width -= value.translation.width
                            cropRect.size.height += value.translation.height
                        case .bottomRight:
                            cropRect.size.width += value.translation.width
                            cropRect.size.height += value.translation.height
                        }
                        cropRect.size.width = max(cropRect.size.width, 50)
                        cropRect.size.height = max(cropRect.size.height, 50)
                    }
            )
    }
}

