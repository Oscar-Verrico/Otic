//
//  ContentView.swift
//  Aural
//
//  Created by Oscar Verrico on 11/4/24.
//

import SwiftUI
import Foundation
import AVFoundation
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var playbackManager = AudioPlaybackManager.shared
    @StateObject private var playlistManager = PlaylistManager()
    @State private var searchText: String = ""
    @State private var isDocumentPickerPresented: Bool = false
    @State private var sortOption: SortOption = .name
    @State private var isAscending: Bool = true
    @State private var showSupabasePlaylistsView: Bool = false


    enum Tab {
        case audio
        case playlists
    }

    @State private var selectedTab: Tab = .playlists

    var body: some View {
        NavigationView {
            VStack {
                Picker("Select Tab", selection: $selectedTab) {
                    Text("Audio Files").tag(Tab.audio)
                    Text("Playlists").tag(Tab.playlists)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if selectedTab == .audio {
                    audioFilesTab
                } else {
                    playlistsTab
                }
            }
            .navigationTitle("Aural App")
        }
    }

    private var audioFilesTab: some View {
        VStack {
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

            List(filteredAndSortedAudioFiles, id: \.id) { audioItem in
                HStack {
                    VStack(alignment: .leading) {
                        Text(audioItem.url.lastPathComponent)
                            .font(.headline)
                    }
                    Spacer()
                    Button("Play") {
                        playbackManager.playAudioFile(audioItem.url)
                    }
                    Menu("Add to Playlist") {
                        ForEach(playlistManager.playlists) { playlist in
                            Button(playlist.name) {
                                playlistManager.addAudioFile(to: playlist.id, fileID: audioItem.id)
                            }
                        }
                    }
                }
            }

            // Loop and Shuffle Buttons
            HStack {
                Button(action: {
                    playbackManager.isShuffleEnabled.toggle()
                    playbackManager.playPlaylist(filteredAndSortedAudioFiles)
                }) {
                    Image(systemName: playbackManager.isShuffleEnabled ? "shuffle.circle.fill" : "shuffle.circle")
                        .font(.system(size: 36))
                        .foregroundColor(playbackManager.isShuffleEnabled ? .blue : .gray)
                }

                Button(action: {
                    playbackManager.isLoopEnabled.toggle()
                }) {
                    Image(systemName: playbackManager.isLoopEnabled ? "repeat.circle.fill" : "repeat.circle")
                        .font(.system(size: 36))
                        .foregroundColor(playbackManager.isLoopEnabled ? .blue : .gray)
                }
            }
            .padding()

            // Add Audio Button
            Button(action: { isDocumentPickerPresented = true }) {
                Text("Add Audio File")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .sheet(isPresented: $isDocumentPickerPresented) {
                DocumentPicker { url in
                    if let fileURL = url {
                        playlistManager.addAudioFile(fileURL)
                    }
                }
            }
        }
    }

    private var playlistsTab: some View {
        VStack {
            // Search, Sort, and Toggle Ascending/Descending
            HStack {
                TextField("Search Playlists", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Menu("Sort by") {
                    Button("Name") { sortOption = .name }
                    Button("Date Created") { sortOption = .dateAdded }
                    //Button("Total Duration") {sortOption = .length}
                    Button("Number of Items") { sortOption = .numberOfItems }
                    Button("Last Modified") { sortOption = .lastModified }
                }
                .padding(.horizontal)

                Button(action: { isAscending.toggle() }) {
                    Image(systemName: isAscending ? "arrow.up" : "arrow.down")
                        .font(.system(size: 20))
                        .padding()
                }
            }

            List(filteredAndSortedPlaylists, id: \.id) { playlist in
                NavigationLink(
                    destination: PlaylistDetailView(
                        playlistManager: playlistManager,
                        playlist: playlist
                    )
                ) {
                    HStack {
                        if let thumbnail = playlist.uiThumbnail {
                            Image(uiImage: thumbnail)
                                .resizable()
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                                .padding(.trailing, 8)
                        } else {
                            Image(systemName: playlist.defaultThumbnail)
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding(.trailing, 8)
                        }
                        Text(playlist.name)
                    }
                }
            }

            // Add Playlist Button
            Button(action: {
                let newPlaylistName = generateUniquePlaylistName()
                playlistManager.playlists.append(
                    Playlist(id: UUID(), name: newPlaylistName, defaultThumbnail: "music.note.list", dateAdded: Date())
                )
            }) {
                Text("Add Playlist")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Button(action: {
                showSupabasePlaylistsView = true
            }) {
                Text("Add from Supabase")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .sheet(isPresented: $showSupabasePlaylistsView) {
                SupabasePlaylistsView()
                    .environmentObject(playlistManager)

            }


        }
    }

    private var filteredAndSortedAudioFiles: [AudioItem] {
        let filteredFiles = playlistManager.audioFiles.filter {
            searchText.isEmpty || $0.url.lastPathComponent.localizedCaseInsensitiveContains(searchText)
        }
        return SortingUtility.sortFiles(filteredFiles, by: sortOption, ascending: isAscending)
    }

    private var filteredAndSortedPlaylists: [Playlist] {
        let filteredPlaylists = playlistManager.playlists.filter {
            searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
        }
        return SortingUtility.sortPlaylists(filteredPlaylists, by: sortOption, ascending: isAscending)
    }

    private func generateUniquePlaylistName() -> String {
        var index = 1
        while playlistManager.playlists.contains(where: { $0.name == "Playlist \(index)" }) {
            index += 1
        }
        return "Playlist \(index)"
    }
}
