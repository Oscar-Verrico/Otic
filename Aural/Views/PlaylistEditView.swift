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
    var playlistIndex: Int
    @Binding var isPresented: Bool
    @State private var newName: String = ""
    @State private var isDeleteConfirmationPresented: Bool = false
    @State private var isPhotoPickerPresented: Bool = false
    @State private var selectedThumbnail: UIImage?

    var body: some View {
        VStack {
            if let playlist = playlistManager.playlists[safe: playlistIndex] { // Use safe array access
                // Edit playlist name
                HStack {
                    TextField("Playlist Name", text: $newName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Save") {
                        if !newName.isEmpty {
                            playlistManager.updatePlaylistName(at: playlistIndex, to: newName)
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()

                // Set Thumbnail
                Button(action: {
                    isPhotoPickerPresented = true
                }) {
                    HStack {
                        if let thumbnail = selectedThumbnail {
                            Image(uiImage: thumbnail)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                .padding(.trailing, 8)
                        } else {
                            Image(systemName: playlist.defaultThumbnail)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .padding(.trailing, 8)
                        }
                        Text("Set Thumbnail")
                            .fontWeight(.medium)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
                .sheet(isPresented: $isPhotoPickerPresented) {
                    PhotoPicker { selectedImages in
                        if let firstImage = selectedImages.first {
                            selectedThumbnail = firstImage
                            playlistManager.updatePlaylistThumbnail(at: playlistIndex, to: firstImage)
                        }
                    }
                }

                // Reset Thumbnail
                Button("Reset to Default Thumbnail") {
                    selectedThumbnail = nil
                    playlistManager.updatePlaylistThumbnail(at: playlistIndex, to: nil)
                }
                .padding()
                .background(Color.orange.opacity(0.2))
                .cornerRadius(8)

                // Add to Supabase
                Button(action: {
                    if let playlist = playlistManager.playlists[safe: playlistIndex] {
                        SupabaseService.shared.insertPlaylist(playlist) { result in
                            switch result {
                            case .success:
                                print("Playlist uploaded successfully.")
                            case .failure(let error):
                                print("Failed to upload playlist: \(error.localizedDescription)")
                            }
                        }
                    }
                }) {
                    Text("Add to Supabase")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }


                // Delete Playlist
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
                            playlistManager.deletePlaylist(at: playlistIndex)
                            isPresented = false
                        },
                        secondaryButton: .cancel()
                    )
                }
            } else {
                // Display an error if the playlist no longer exists
                Text("The playlist no longer exists.")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationTitle("Edit Playlist")
        .onAppear {
            if let playlist = playlistManager.playlists[safe: playlistIndex] {
                newName = playlist.name
                selectedThumbnail = playlist.uiThumbnail
            }
        }
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
