//
//  NetworkService.swift
//  BusterAI
//
//  Created by b on 13.11.2025.
//
import Foundation
import UIKit
internal import Combine

class ReverseSearchAPI {
    static let shared = ReverseSearchAPI()
    private let baseURL = "https://cheaterbuster.webberapp.shop"
    
    var accessToken: String? {
        KeyChainService.shared.loadKeychain(key: "access_token")
    }
    
    var userId: String? {
        KeyChainService.shared.loadKeychain(key: "user_id")
    }
    
    var apphudId: String {
        if let id = KeyChainService.shared.loadKeychain(key: "apphud_id"), !id.isEmpty {
            return id
        } else {
            let id = UUID().uuidString
            KeyChainService.shared.saveKeychain(value: id, key: "apphud_id")
            return id
        }
    }
    
    func ensureUser(completion: @escaping (Result<String, Error>) -> Void) {
        if let _ = userId, let token = accessToken {
            completion(.success(token))
        } else {
            createUser(apphudId: apphudId) { [weak self] result in
                switch result {
                case .success(let userId):
                    KeyChainService.shared.saveKeychain(value: userId, key: "user_id")
                    self?.authorizeUser(userId: userId) { authResult in
                        switch authResult {
                        case .success(let token):
                            KeyChainService.shared.saveKeychain(value: token, key: "access_token")
                            completion(.success(token))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func createUser(apphudId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/user") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["apphud_id": apphudId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(UserResponse.self, from: data)
                completion(.success(response.id ?? ""))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func authorizeUser(userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/user/authorize") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["user_id": userId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(AuthorizeResponse.self, from: data)
                completion(.success(response.access_token ?? ""))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchCurrentUser(completion: @escaping (Result<UserResponse, Error>) -> Void) {
        guard let token = accessToken, let url = URL(string: "\(baseURL)/api/user/me") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(UserResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func createSearchTask(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        ensureUser { [weak self] result in
            switch result {
            case .success(let token):
                guard let self = self, let url = URL(string: "\(self.baseURL)/api/search") else { return }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                let boundary = UUID().uuidString
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.httpBody = self.createMultipartData(image: image, boundary: boundary)
                
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        DispatchQueue.main.async { completion(.failure(error)) }
                        return
                    }
                    guard let data = data, let httpResponse = response as? HTTPURLResponse else { return }
                    if httpResponse.statusCode != 200 {
                        let text = String(data: data, encoding: .utf8) ?? "No response text"
                        DispatchQueue.main.async {
                            completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: text])))
                        }
                        return
                    }
                    
                    do {
                        let decoded = try JSONDecoder().decode(ReverseSearchTaskResponse.self, from: data)
                        DispatchQueue.main.async { completion(.success(decoded.task_id ?? "")) }
                    } catch {
                        let text = String(data: data, encoding: .utf8) ?? "No response text"
                        print("Decoding error, raw response: \(text)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                }.resume()
            case .failure(let error):
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }
    
    func getSearchStatus(taskId: String, completion: @escaping (Result<ReverseSearchStatusResponse, Error>) -> Void) {
        ensureUser { [weak self] result in
            switch result {
            case .success(let token):
                guard let self = self, let url = URL(string: "\(self.baseURL)/api/search/\(taskId)") else { return }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        DispatchQueue.main.async { completion(.failure(error)) }
                        return
                    }
                    guard let data = data else { return }
                    do {
                        let response = try JSONDecoder().decode(ReverseSearchStatusResponse.self, from: data)
                        DispatchQueue.main.async { completion(.success(response)) }
                    } catch {
                        let text = String(data: data, encoding: .utf8) ?? "No response text"
                        print("Decoding error, raw response: \(text)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                }.resume()
            case .failure(let error):
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }
    
    private func createMultipartData(image: UIImage, boundary: String) -> Data {
        var data = Data()
        let imageData = image.jpegData(compressionQuality: 0.9) ?? Data()
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(imageData)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        return data
    }
}


class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var url: URL?

    init(url: URL?) {
        self.url = url
        load()
    }

    func load() {
        guard let url = url else { return }
        if let cached = URLCache.shared.cachedResponse(for: URLRequest(url: url))?.data,
           let uiImage = UIImage(data: cached) {
            self.image = uiImage
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, _ in
            guard let data = data, let response = response, let uiImage = UIImage(data: data) else { return }
            let cachedData = CachedURLResponse(response: response, data: data)
            URLCache.shared.storeCachedResponse(cachedData, for: URLRequest(url: url))
            DispatchQueue.main.async {
                self.image = uiImage
            }
        }.resume()
    }
}

extension Data {
    func fixGoogleBrokenField() -> Data {
        var string = String(decoding: self, as: UTF8.self)
        if let range = string.range(of: "\"google\":{") {
            let googleStart = range.lowerBound
            if let end = string.range(of: "},\"yandex\":")?.lowerBound {
                string.removeSubrange(googleStart..<end)
                string.insert(contentsOf: "\"google\":null,", at: googleStart)
            }
        }

        return Data(string.utf8)
    }
}
