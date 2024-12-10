//
//  AudioItem.swift
//  Aural
//
//  Created by Oscar Verrico on 12/4/24.
//

import Foundation
import AVFoundation

import Foundation
import AVFoundation

class AudioItem: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let url: URL
    var hasBeenPlayed: Bool
    var fileSize: Int
    weak var next: AudioItem? = nil
    weak var prev: AudioItem? = nil
    var duration: TimeInterval?
    let dateAdded: Date

    enum CodingKeys: String, CodingKey {
        case id
        case url
        case hasBeenPlayed
        case fileSize
        case duration
        case dateAdded
    }

    // Custom initializer for new instances
    init(url: URL) {
        self.id = UUID()
        self.url = url
        self.hasBeenPlayed = false
        self.fileSize = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
        self.duration = try? AVAudioPlayer(contentsOf: url).duration
        self.dateAdded = Date()
    }

    // Required initializer for Decodable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID(uuidString: try container.decode(String.self, forKey: .id))!
        url = URL(string: try container.decode(String.self, forKey: .url))!
        hasBeenPlayed = try container.decode(Bool.self, forKey: .hasBeenPlayed)
        fileSize = try container.decode(Int.self, forKey: .fileSize)
        duration = try container.decodeIfPresent(TimeInterval.self, forKey: .duration)
        dateAdded = try container.decode(Date.self, forKey: .dateAdded)
    }

    // Encode properties for Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(url.absoluteString, forKey: .url)
        try container.encode(hasBeenPlayed, forKey: .hasBeenPlayed)
        try container.encode(fileSize, forKey: .fileSize)
        try container.encode(duration, forKey: .duration)
        try container.encode(dateAdded, forKey: .dateAdded)
    }

    static func == (lhs: AudioItem, rhs: AudioItem) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
