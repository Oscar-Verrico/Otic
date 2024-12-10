//
//  SortingUtility.swift
//  Aural
//
//  Created by Oscar Verrico on 12/6/24.
//

import Foundation

class SortingUtility {
    // Sorts a list of audio files based on the provided sorting option and order.
    static func sortFiles(
        _ files: [AudioItem],
        by option: SortOption,
        ascending: Bool
    ) -> [AudioItem] {
        switch option {
        case .name:
            return files.sorted { (lhs: AudioItem, rhs: AudioItem) -> Bool in
                ascending
                    ? lhs.url.lastPathComponent.localizedCaseInsensitiveCompare(rhs.url.lastPathComponent) == .orderedAscending
                    : lhs.url.lastPathComponent.localizedCaseInsensitiveCompare(rhs.url.lastPathComponent) == .orderedDescending
            }
        case .size:
            return files.sorted { (lhs: AudioItem, rhs: AudioItem) -> Bool in
                ascending ? lhs.fileSize < rhs.fileSize : lhs.fileSize > rhs.fileSize
            }
        case .fileType:
            return files.sorted { (lhs: AudioItem, rhs: AudioItem) -> Bool in
                ascending ? lhs.url.pathExtension < rhs.url.pathExtension : lhs.url.pathExtension > rhs.url.pathExtension
            }
        case .dateAdded:
            return files.sorted { (lhs: AudioItem, rhs: AudioItem) -> Bool in
                ascending ? lhs.dateAdded < rhs.dateAdded : lhs.dateAdded > rhs.dateAdded
            }
        default:
            return files // Unsupported sort option for audio files
        }
    }

    // Sorts a list of playlists based on the provided sorting option and order.
    static func sortPlaylists(
        _ playlists: [Playlist],
        by option: SortOption,
        ascending: Bool
    ) -> [Playlist] {
        switch option {
        case .name:
            return playlists.sorted { (lhs: Playlist, rhs: Playlist) -> Bool in
                ascending
                    ? lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                    : lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedDescending
            }
        case .dateAdded:
            return playlists.sorted { (lhs: Playlist, rhs: Playlist) -> Bool in
                ascending ? lhs.dateAdded < rhs.dateAdded : lhs.dateAdded > rhs.dateAdded
            }
        case .length:
            return playlists.sorted { (lhs: Playlist, rhs: Playlist) -> Bool in
                ascending ? lhs.length < rhs.length : lhs.length > rhs.length
            }
        case .numberOfItems:
            return playlists.sorted { (lhs: Playlist, rhs: Playlist) -> Bool in
                ascending ? lhs.audioFileIDs.count < rhs.audioFileIDs.count : lhs.audioFileIDs.count > rhs.audioFileIDs.count
            }
        case .lastModified:
            return playlists.sorted { (lhs: Playlist, rhs: Playlist) -> Bool in
                ascending ? lhs.lastModified < rhs.lastModified : lhs.lastModified > rhs.lastModified
            }
        default:
            return playlists // Unsupported sort option for playlists
        }
    }
}
