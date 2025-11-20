//
//  NetworkModels.swift
//  BusterAI
//
//  Created by b on 13.11.2025.
//

import Foundation

struct UserResponse: Codable {
    let id: String
    let apphud_id: String
    let tokens: Int
}

struct AuthorizeResponse: Codable {
    let access_token: String
    let token_type: String
}

// MARK: - Task Response
struct ReverseSearchTaskResponse: Codable {
    let task_id: String
}

struct ReverseSearchStatusResponse: Codable, Identifiable {
    let status: SearchStatus?
    let results: SearchResults?

    var id: String { status?.google ?? UUID().uuidString }
}

// MARK: - Status
struct SearchStatus: Codable {
    let google: String?
    let yandex: String?
    let bing: String?
}

// MARK: - Results
struct SearchResults: Codable {
    let google: GoogleResult?
    let yandex: YandexResult?
    let bing: BingResult?
}

// MARK: - Google
struct GoogleResult: Codable {
    let search_metadata: GoogleMetadata?
    let search_parameters: GoogleParameters?
    let visual_matches: [GoogleVisualMatch]?
}

struct GoogleMetadata: Codable {
    let id: String?
    let status: String?
    let json_endpoint: String?
    let created_at: String?
    let processed_at: String?
    let google_lens_url: String?
    let raw_html_file: String?
    let total_time_taken: Double?
}

struct GoogleParameters: Codable {
    let engine: String?
    let url: String?
}

struct GoogleVisualMatch: Codable {
    let position: Double?
    let title: String?
    let link: String?
    let source: String?
    let source_icon: String?
    let thumbnail: String?
    let thumbnail_width: Double?
    let thumbnail_height: Double?
    let image: String?
    let image_width: Double?
    let image_height: Double?
}

// MARK: - Yandex
struct YandexResult: Codable {
    let knowledge_graph: [YandexKnowledgeGraph]?
    let image_tags: [YandexImageTag]?
    let image_results: [YandexImageResult]?
    let similiar_images: [YandexSimilarImage]?
}

struct YandexKnowledgeGraph: Codable {
    let title: String?
    let subtitle: String?
    let description: String?
    let link: String?
    let source: String?
    let thumbnail: String?
}

struct YandexImageTag: Codable {
    let text: String?
    let link: String?
    let serpapi_link: String?
}

struct YandexImageResult: Codable {
    let title: String?
    let snippet: String?
    let link: String?
    let source: String?
    let thumbnail: YandexImageInfo?
    let original_image: YandexImageInfo?
}

struct YandexSimilarImage: Codable {
    let image: YandexImageInfo?
    let link: String?
}

struct YandexImageInfo: Codable {
    let link: String?
    let serpapi_link: String?
    let height: Int?
    let width: Int?
}

// MARK: - Bing
struct BingResult: Codable {
    let related_content: [BingRelatedContent]?
    let pages_with_this_image: [String]?
    let looks_like: [BingLooksLike]?
    let related_searches: [BingRelatedSearch]?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let single = try? container.decode(BingLooksLike.self, forKey: .looks_like) {
            looks_like = [single]
        } else {
            looks_like = try? container.decode([BingLooksLike].self, forKey: .looks_like)
        }
        pages_with_this_image = try? container.decode([String].self, forKey: .pages_with_this_image)
        related_content = try? container.decode([BingRelatedContent].self, forKey: .related_content)
        related_searches = try? container.decode([BingRelatedSearch].self, forKey: .related_searches)
    }
}

struct BingRelatedContent: Codable {
    let position: Int?
    let title: String?
    let link: String?
    let thumbnail: String?
    let date: String?
    let source: String?
    let original: String?
    let cdn_original: String?
    let domain: String?
    let format: String?
}

struct BingLooksLike: Codable {
    let title: String?
    let link: String?
    let thumbnail: String?
    let source: String?
    let description: String?
    let social_media_info: [BingSocialInfo]?
    let type: String?
}

struct BingSocialInfo: Codable {
    let url: String?
    let name: String?
}

struct BingRelatedSearch: Codable {
    let name: String?
    let link: String?
    let thumbnail: String?
    let serpapi_link: String?
}

