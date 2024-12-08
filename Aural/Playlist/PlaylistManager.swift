//
//  PlaylistManager.swift
//  Aural
//
//  Created by Oscar Verrico on 11/24/24.
//
import SwiftUI
import AVFoundation

import SwiftUI

class PlaylistManager: ObservableObject {
    @Published var playlists: [Playlist] = []
    @Published var fileTags: [URL: Int] = [:] // Stores tags for audio files

    func createPlaylist(name: String, thumbnail: String) {
        playlists.append(Playlist(name: name, thumbnail: thumbnail))
    }

    func addAudioItem(to playlistID: UUID, item: AudioItem) {
        if let index = playlists.firstIndex(where: { $0.id == playlistID }) {
            playlists[index].audioItems.append(item)
        }
    }

    func deletePlaylist(_ playlistID: UUID) {
        playlists.removeAll { $0.id == playlistID }
    }

    func getPlaylist(by id: UUID) -> Playlist? {
        return playlists.first { $0.id == id }
    }
}
