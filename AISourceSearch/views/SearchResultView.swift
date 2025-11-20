//
//  SearchResultView.swift
//  BusterAI
//
//  Created by b on 13.11.2025.
//

import SwiftUI

struct SearchResultView: View {
    let searchResult: ReverseSearchStatusResponse
    @Environment(\.dismiss) var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    private let cellHeight: CGFloat = 180
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(hex: "121212").opacity(0.8))
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle()) 
                }

                Spacer()
                Text("Search result")
                    .foregroundColor(.black)
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .offset(x: -10)

                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 70)

            if (searchResult.results?.google?.visual_matches?.isEmpty ?? true) &&
                (searchResult.results?.yandex?.image_results?.isEmpty ?? true) &&
                (searchResult.results?.bing?.related_content?.isEmpty ?? true) {
                
                VStack(spacing: 8) {
                    Image(.noFound)
                    Text("No results found")
                        .foregroundColor(.black)
                        .font(.title3)
                        .bold()
                    Text("Try adjusting your search or upload another photo.")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if let googleMatches = searchResult.results?.google?.visual_matches, !googleMatches.isEmpty {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(googleMatches.indices, id: \.self) { index in
                                    let match = googleMatches[index]
                                    SearchResultCell(title: match.title ?? "",
                                                     link: match.link ?? "",
                                                     thumbnail: match.thumbnail)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        if let yandexMatches = searchResult.results?.yandex?.image_results, !yandexMatches.isEmpty {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(yandexMatches.indices, id: \.self) { index in
                                    let match = yandexMatches[index]
                                    SearchResultCell(title: match.title ?? "",
                                                     link: match.link ?? "",
                                                     thumbnail: match.thumbnail?.link)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        if let bingMatches = searchResult.results?.bing?.related_content, !bingMatches.isEmpty {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(bingMatches.indices, id: \.self) { index in
                                    let match = bingMatches[index]
                                    SearchResultCell(title: match.title ?? "",
                                                     link: match.link ?? "",
                                                     thumbnail: match.thumbnail)
                                }
                            }
                            .padding(.horizontal)
                        }
                        Spacer().frame(height: 200)
                    }
                    .padding(.vertical)
                }
                .background(Color(hex: "F4F6F8"))
            }
        }
        .background(Color(hex: "F4F6F8"))
    }
}

struct SearchResultCell: View {
    let title: String
    let link: String
    let thumbnail: String?
    
    @StateObject private var loader: ImageLoader

    init(title: String, link: String, thumbnail: String?) {
        self.title = title
        self.link = link
        self.thumbnail = thumbnail
        _loader = StateObject(wrappedValue: ImageLoader(url: URL(string: thumbnail ?? "")))
    }

    var body: some View {
        VStack(spacing: 0) {
            if let uiImage = loader.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 170, height: 160)
                    .clipped()
                    .clipShape(RoundedCorners(radius: 8, corners: [.allCorners]))
            } else {
                Color.gray
                    .frame(width: 170, height: 160)
                    .clipShape(RoundedCorners(radius: 8, corners: [.allCorners]))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(link)
                    .foregroundColor(.gray)
                    .font(.caption2)
                    .lineLimit(1)
                Text(title)
                    .foregroundColor(.black)
                    .font(.subheadline)
                    .lineLimit(2)
            }
            .padding(6)
            .frame(width: 170, height: 50, alignment: .topLeading)
            .clipShape(RoundedCorners(radius: 8, corners: [.allCorners]))
        }
        .onTapGesture {
            guard let url = URL(string: link) else { return }
            UIApplication.shared.open(url)
        }
    }
}

struct RoundedCorners: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
