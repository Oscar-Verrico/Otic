//
//  PlaylistEditView.swift
//  Aural
//
//  Created by Oscar Verrico on 12/5/24.
//
import SwiftUI
import PhotosUI

struct PlaylistEditView: View {
    @ObservedObject var playlistManager: PlaylistManager
    var playlist: Playlist
    @Binding var isPresented: Bool
    @State private var newName: String
    @State private var isDeleteConfirmationPresented: Bool = false

    init(playlistManager: PlaylistManager, playlist: Playlist, isPresented: Binding<Bool>) {
        self.playlistManager = playlistManager
        self.playlist = playlist
        _isPresented = isPresented
        _newName = State(initialValue: playlist.name)
    }

    var body: some View {
        VStack {
            HStack {
                TextField("Playlist Name", text: $newName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Save") {
                    if let index = playlistManager.playlists.firstIndex(where: { $0.id == playlist.id }) {
                        playlistManager.playlists[index].name = newName
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()

            Button("Delete Playlist") {
                isDeleteConfirmationPresented = true
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
            .alert(isPresented: $isDeleteConfirmationPresented) {
                Alert(
                    title: Text("Delete Playlist"),
                    message: Text("Are you sure you want to delete this playlist?"),
                    primaryButton: .destructive(Text("Delete")) {
                        playlistManager.deletePlaylist(playlist.id)
                        isPresented = false
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .navigationTitle("Edit Playlist")
    }
}
