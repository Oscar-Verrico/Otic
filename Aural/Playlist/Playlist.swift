//
//  Playlist.swift
//  Aural
//
//  Created by Oscar Verrico on 11/24/24.
//

import Foundation
import UIKit

struct Playlist: Identifiable, Codable {
    let id: UUID
    var name: String
    var defaultThumbnail: String
    var thumbnail: Data? // Store as Data
    var audioFileIDs: [UUID]
    var dateAdded: Date
    var lastModified: Date

    init(
        id: UUID = UUID(),
        name: String,
        defaultThumbnail: String,
        thumbnail: UIImage? = nil,
        audioFileIDs: [UUID] = [],
        dateAdded: Date = Date(),
        lastModified: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.defaultThumbnail = defaultThumbnail
        self.thumbnail = thumbnail?.jpegData(compressionQuality: 0.8) // Convert UIImage to Data
        self.audioFileIDs = audioFileIDs
        self.dateAdded = dateAdded
        self.lastModified = lastModified
    }

    var uiThumbnail: UIImage? {
        guard let data = thumbnail else { return nil }
        return UIImage(data: data) // Convert Data back to UIImage
    }

    // Computed property for playlist length
    var length: TimeInterval {
        let audioItems = audioFileIDs.compactMap { PlaylistManager.shared.getAudioItem(by: $0) }
        return audioItems.reduce(0) { $0 + ($1.duration ?? 0) }
    }
}
