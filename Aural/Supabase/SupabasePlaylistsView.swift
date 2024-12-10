//
//  SupabasePlaylistsView.swift
//  Aural
//
//  Created by Oscar Verrico on 12/10/24.
//

import SwiftUI

struct SupabasePlaylistsView: View {
    @EnvironmentObject var playlistManager: PlaylistManager
    @State private var supabasePlaylists: [Playlist] = []
    @State private var isLoading = false

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading playlists...")
            } else {
                List {
                    ForEach(supabasePlaylists, id: \.id) { playlist in
                        HStack {
                            Text(playlist.name)
                            Spacer()
                            Button("Download") {
                                downloadPlaylist(playlist)
                            }
                            Button("Delete") {
                                deletePlaylist(playlist)
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .onAppear(perform: loadPlaylists)
        .navigationTitle("Supabase Playlists")
    }

    private func loadPlaylists() {
        isLoading = true
        SupabaseService.shared.fetchAllPlaylists { result in
            isLoading = false
            switch result {
            case .success(let playlists):
                supabasePlaylists = playlists
            case .failure(let error):
                print("Error loading playlists: \(error.localizedDescription)")
            }
        }
    }

    private func downloadPlaylist(_ playlist: Playlist) {
        SupabaseService.shared.fetchAudioFiles(forPlaylistID: playlist.id) { result in
            switch result {
            case .success(let audioFiles):
                playlistManager.playlists.append(playlist)
                playlistManager.audioFiles.append(contentsOf: audioFiles)
                print("Playlist downloaded successfully.")
            case .failure(let error):
                print("Error downloading playlist: \(error.localizedDescription)")
            }
        }
    }

    private func deletePlaylist(_ playlist: Playlist) {
        SupabaseService.shared.deletePlaylist(byID: playlist.id) { result in
            switch result {
            case .success:
                supabasePlaylists.removeAll { $0.id == playlist.id }
                print("Playlist deleted successfully.")
            case .failure(let error):
                print("Error deleting playlist: \(error.localizedDescription)")
            }
        }
    }
}
