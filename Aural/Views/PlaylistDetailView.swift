//
//  PlaylistDetailView.swift
//  Aural
//
//  Created by Oscar Verrico on 11/24/24.
//

import SwiftUI

struct PlaylistDetailView: View {
    @ObservedObject var playlistManager: PlaylistManager
    var playlist: Playlist
    @State private var searchText: String = ""
    @State private var sortOption: SortOption = .name
    @State private var isAscending: Bool = true
    @State private var isDocumentPickerPresented: Bool = false
    @State private var isShuffleEnabled: Bool = false
    @State private var isLoopEnabled: Bool = false
    @State private var isEditViewPresented: Bool = false
    @State private var isPlaying: Bool = false

    var body: some View {
        VStack {
            // Display playlist thumbnail or default icon
            if let thumbnail = playlist.uiThumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
            } else {
                Image(systemName: playlist.defaultThumbnail)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .clipped()
            }

            // Playlist Name and Edit Button
            HStack {
                Text(playlist.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                Spacer()

                Button(action: {
                    isEditViewPresented = true // Show the edit view
                }) {
                    Text("Edit")
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.trailing)
            }
            .sheet(isPresented: $isEditViewPresented) {
                PlaylistEditView(
                    playlistManager: playlistManager,
                    playlistIndex: playlistManager.playlists.firstIndex(where: { $0.id == playlist.id }) ?? 0,
                    isPresented: $isEditViewPresented
                )
            }

            // Add, Shuffle, Loop, and Play/Stop Buttons
            HStack {
                Button(action: {
                    isDocumentPickerPresented = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Audio")
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .sheet(isPresented: $isDocumentPickerPresented) {
                    DocumentPicker { url in
                        if let fileURL = url {
                            playlistManager.addAudioFile(fileURL)
                            if let audioItem = playlistManager.audioFiles.first(where: { $0.url == fileURL }) {
                                playlistManager.addAudioFile(to: playlist.id, fileID: audioItem.id)
                            }
                        }
                    }
                }

                Button(action: {
                    isShuffleEnabled.toggle()
                    let items = playlistManager.getAudioItems(for: playlist)
                    AudioPlaybackManager.shared.playPlaylist(isShuffleEnabled ? items.shuffled() : items)
                }) {
                    Image(systemName: isShuffleEnabled ? "shuffle.circle.fill" : "shuffle.circle")
                        .font(.system(size: 36))
                        .foregroundColor(isShuffleEnabled ? .blue : .gray)
                }

                Button(action: {
                    isLoopEnabled.toggle()
                    AudioPlaybackManager.shared.isLoopEnabled = isLoopEnabled
                }) {
                    Image(systemName: isLoopEnabled ? "repeat.circle.fill" : "repeat.circle")
                        .font(.system(size: 36))
                        .foregroundColor(isLoopEnabled ? .blue : .gray)
                }

                Button(action: {
                    if isPlaying {
                        AudioPlaybackManager.shared.stopPlayback()
                    } else {
                        let items = playlistManager.getAudioItems(for: playlist)
                        AudioPlaybackManager.shared.playPlaylist(items)
                    }
                    isPlaying.toggle()
                }) {
                    Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(isPlaying ? .red : .blue)
                }
            }
            .padding()

            // Search, Sort, and Toggle Ascending/Descending
            HStack {
                TextField("Search Audio Files", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Menu("Sort by") {
                    Button("Name") { sortOption = .name }
                    Button("Date Added") { sortOption = .dateAdded }
                    Button("Duration") { sortOption = .length }
                    Button("Size") { sortOption = .size }
                }
                .padding(.horizontal)

                Button(action: { isAscending.toggle() }) {
                    Image(systemName: isAscending ? "arrow.up" : "arrow.down")
                        .font(.system(size: 20))
                        .padding()
                }
            }

            // Filtered and Sorted List of Playlist Items
            List(filteredAndSortedAudioFiles, id: \.id) { audioItem in
                HStack {
                    VStack(alignment: .leading) {
                        Text(audioItem.url.lastPathComponent)
                            .font(.headline)
                        Text(formatDuration(audioItem.duration ?? 0))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button(action: {
                        playlistManager.removeAudioFile(from: playlist.id, fileID: audioItem.id)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }

    // Filtered and Sorted Audio Files
    private var filteredAndSortedAudioFiles: [AudioItem] {
        let items = playlistManager.getAudioItems(for: playlist)
        let filteredItems = items.filter {
            searchText.isEmpty || $0.url.lastPathComponent.localizedCaseInsensitiveContains(searchText)
        }
        return SortingUtility.sortFiles(filteredItems, by: sortOption, ascending: isAscending)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
