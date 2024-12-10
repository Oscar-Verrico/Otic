//
//  PlaylistManager.swift
//  Aural
//
//  Created by Oscar Verrico on 11/24/24.
//

//
//  PlaylistManager.swift
//  Aural
//
//  Created by Oscar Verrico on 11/24/24.
//

import Foundation
import SwiftUI
import AVFoundation

class PlaylistManager: ObservableObject {
    static let shared = PlaylistManager() // Singleton instance

    @Published var audioFiles: [AudioItem] = [] // Centralized collection of audio files
    @Published var playlists: [Playlist] = [] // Playlists reference audio files by UUID
    @Published var fileTags: [UUID: Int] = [:] // Tags mapped to audio file UUIDs

    init() {} // Prevent external initialization

    // Add an audio file to the centralized collection
    func addAudioFile(_ fileURL: URL) {
        guard !audioFiles.contains(where: { $0.url == fileURL }) else {
            print("Duplicate file: \(fileURL.lastPathComponent)")
            return
        }
        let newAudioItem = AudioItem(url: fileURL)
        audioFiles.append(newAudioItem)
        print("Audio File Added: \(fileURL.lastPathComponent)")
    }

    // Fetch an audio item by UUID
    func getAudioItem(by id: UUID) -> AudioItem? {
        return audioFiles.first { $0.id == id }
    }

    // Add a file reference to a playlist
    func addAudioFile(to playlistID: UUID, fileID: UUID) {
        guard let index = playlists.firstIndex(where: { $0.id == playlistID }) else { return }
        guard !playlists[index].audioFileIDs.contains(fileID) else {
            print("File already exists in playlist")
            return
        }
        playlists[index].audioFileIDs.append(fileID)
        playlists[index].lastModified = Date() // Update the last modified date
    }

    // Remove a file reference from a playlist
    func removeAudioFile(from playlistID: UUID, fileID: UUID) {
        guard let playlistIndex = playlists.firstIndex(where: { $0.id == playlistID }) else { return }
        playlists[playlistIndex].audioFileIDs.removeAll { $0 == fileID }
        playlists[playlistIndex].lastModified = Date() // Update the last modified date
    }

    // Delete an audio file globally
    func deleteAudioFile(_ audioFile: AudioItem) {
        // Remove from global audio files
        audioFiles.removeAll { $0.id == audioFile.id }

        // Remove references from all playlists
        for (index, _) in playlists.enumerated() {
            playlists[index].audioFileIDs.removeAll { $0 == audioFile.id }
        }
    }

    // Get all audio items referenced by a playlist
    func getAudioItems(for playlist: Playlist) -> [AudioItem] {
        return playlist.audioFileIDs.compactMap { getAudioItem(by: $0) }
    }

    // Update playlist name
    func updatePlaylistName(at index: Int, to newName: String) {
        guard index < playlists.count else { return }
        playlists[index].name = newName
        playlists[index].lastModified = Date() // Update the last modified date
    }

    // Update playlist thumbnail
    func updatePlaylistThumbnail(at index: Int, to thumbnail: UIImage?) {
        guard index < playlists.count else { return }
        playlists[index].thumbnail = thumbnail?.jpegData(compressionQuality: 0.8) // Convert UIImage to Data
        playlists[index].lastModified = Date() // Update the last modified date
    }

    // Delete a playlist
    func deletePlaylist(at index: Int) {
        guard index < playlists.count else { return }
        playlists.remove(at: index)
    }

    // Set tags for an audio file
    func setTag(for fileID: UUID, tag: Int) {
        fileTags[fileID] = tag
    }

    // Get tags for an audio file
    func getTag(for fileID: UUID) -> Int? {
        return fileTags[fileID]
    }
}
