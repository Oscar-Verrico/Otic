//
//  Playlist.swift
//  Aural
//
//  Created by Oscar Verrico on 11/24/24.
//
import SwiftUI

struct Playlist: Identifiable {
    let id: UUID = UUID()
    var name: String
    var thumbnail: String // SF Symbol for the thumbnail
    var audioItems: [AudioItem] = []
    var dateAdded: Date = Date()
    var isShuffleEnabled: Bool = false
    var isLoopEnabled: Bool = false

    mutating func shuffle() {
        guard !audioItems.isEmpty else { return }
        audioItems.shuffle()
    }

    mutating func updatePointers() {
        guard audioItems.count > 1 else { return }
        for index in 0..<audioItems.count {
            let nextIndex = (index + 1) % audioItems.count
            let prevIndex = (index - 1 + audioItems.count) % audioItems.count
            audioItems[index].next = audioItems[nextIndex]
            audioItems[index].prev = audioItems[prevIndex]
        }
    }

    mutating func resetPlayback() {
        for item in audioItems {
            item.hasBeenPlayed = false
        }
    }
}
