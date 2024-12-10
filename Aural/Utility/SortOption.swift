//
//  SortOption.swift
//  Aural
//
//  Created by Oscar Verrico on 12/6/24.
//

import Foundation

enum SortOption: String, CaseIterable, Identifiable {
    case name = "Name"
    case size = "Size" // For sorting audio files only
    case fileType = "File Type" // For sorting audio files only
    case dateAdded = "Date Added"
    case length = "Length" // For playlists: Total duration of all items
    case numberOfItems = "Number of Items" // For playlists: Count of items
    case lastModified = "Last Modified" // For playlists: Last updated

    var id: String { self.rawValue }

    /// Returns whether this option applies to playlists.
    var isPlaylistOption: Bool {
        switch self {
        case .length, .numberOfItems, .lastModified, .name, .dateAdded:
            return true
        default:
            return false
        }
    }

    /// Returns whether this option applies to audio files.
    var isAudioFileOption: Bool {
        switch self {
        case .size, .fileType, .name, .dateAdded:
            return true
        default:
            return false
        }
    }
}
