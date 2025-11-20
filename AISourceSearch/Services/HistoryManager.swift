//
//  HistoryManager.swift
//  BusterAI
//
//  Created by b on 13.11.2025.
//

import SwiftUI

// MARK: - Модель истории
struct SearchHistoryItem: Identifiable, Codable {
    let id: UUID
    let imageFilename: String 
    let result: ReverseSearchStatusResponse?
    let date: Date
}

// MARK: - Менеджер истории
class HistoryManager {
    static let shared = HistoryManager()
    private let folderName = "History"
    private let metadataFile = "history.json"

    private init() {}

    private var folderURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(folderName)
    }
    
    private func ensureFolderExists() {
        guard let url = folderURL else { return }
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }

    // MARK: - Сохранение записи
    func saveHistory(image: UIImage, result: ReverseSearchStatusResponse?) {
        ensureFolderExists()
        let id = UUID()
        let filename = "\(id.uuidString).jpg"
        guard let imageData = image.jpegData(compressionQuality: 0.8),
              let folder = folderURL else { return }

        let fileURL = folder.appendingPathComponent(filename)
        try? imageData.write(to: fileURL)

        var history = loadHistory()
        let newItem = SearchHistoryItem(id: id, imageFilename: filename, result: result, date: Date())
        history.append(newItem)
        saveMetadata(history: history)
    }

    // MARK: - Сохранение метаданных
    private func saveMetadata(history: [SearchHistoryItem]) {
        guard let folder = folderURL else { return }
        let fileURL = folder.appendingPathComponent(metadataFile)
        if let data = try? JSONEncoder().encode(history) {
            try? data.write(to: fileURL)
        }
    }

    // MARK: - Загрузка истории
    func loadHistory() -> [SearchHistoryItem] {
        guard let folder = folderURL else { return [] }
        let fileURL = folder.appendingPathComponent(metadataFile)
        guard let data = try? Data(contentsOf: fileURL),
              let history = try? JSONDecoder().decode([SearchHistoryItem].self, from: data) else {
            return []
        }
        return history
    }

    // MARK: - Загрузка изображения по имени файла
    func loadImage(filename: String) -> UIImage? {
        guard let folder = folderURL else { return nil }
        let fileURL = folder.appendingPathComponent(filename)
        return UIImage(contentsOfFile: fileURL.path)
    }
}
