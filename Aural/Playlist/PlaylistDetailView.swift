//
//  PlaylistDetailView.swift
//  Aural
//
//  Created by Oscar Verrico on 11/24/24.x
//
import SwiftUI
import AVFoundation

struct PlaylistDetailView: View {
    @ObservedObject var playlistManager: PlaylistManager
    @Binding var searchText: String
    var playlist: Playlist
    @State private var newName: String
    @State private var sortOption: SortOption = .name
    @State private var isAscending: Bool = true

    enum SortOption: String, CaseIterable, Identifiable {
        case name = "Name"
        case size = "Size"
        case fileType = "File Type"
        case tag = "Tag"
        case dateAdded = "Date Added"

        var id: String { self.rawValue }
    }

    init(playlistManager: PlaylistManager, playlist: Playlist, searchText: Binding<String>) {
        self.playlistManager = playlistManager
        self.playlist = playlist
        _searchText = searchText
        _newName = State(initialValue: playlist.name)
    }

    var body: some View {
        VStack {
            // Edit playlist name
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

            // Sort options
            HStack {
                Picker("Sort by", selection: $sortOption) {
                    ForEach(SortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                Button("Toggle Ascending/Descending") {
                    isAscending.toggle()
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            .padding()

            // Filtered and sorted audio files
            List(sortedAudioFiles, id: \.self) { file in
                HStack {
                    Text(file.lastPathComponent)
                    Spacer()
                    if let tag = playlistManager.fileTags[file] {
                        Text("Tag: \(tag)")
                    }
                }
            }
        }
        .navigationTitle(playlist.name)
    }

    // Computed property for sorted and filtered audio files
    private var sortedAudioFiles: [URL] {
        let allAudioFiles = playlist.audioItems.map { $0.url }

        // Filter based on searchText
        let filteredAudioFiles = allAudioFiles.filter {
            searchText.isEmpty || $0.lastPathComponent.localizedCaseInsensitiveContains(searchText)
        }

        // Apply sorting based on current sortOption
        switch sortOption {
        case .name:
            return filteredAudioFiles.sorted {
                isAscending ? $0.lastPathComponent < $1.lastPathComponent : $0.lastPathComponent > $1.lastPathComponent
            }
        case .size:
            return filteredAudioFiles.sorted {
                let lhsSize = (try? $0.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                let rhsSize = (try? $1.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                return isAscending ? lhsSize < rhsSize : lhsSize > rhsSize
            }
        case .fileType:
            return filteredAudioFiles.sorted {
                isAscending ? $0.pathExtension < $1.pathExtension : $0.pathExtension > $1.pathExtension
            }
        case .tag:
            return filteredAudioFiles.sorted {
                let lhsTag = playlistManager.fileTags[$0] ?? 0
                let rhsTag = playlistManager.fileTags[$1] ?? 0
                return isAscending ? lhsTag < rhsTag : lhsTag > rhsTag
            }
        case .dateAdded:
            return filteredAudioFiles.sorted {
                let lhsDate = (try? $0.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                let rhsDate = (try? $1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                return isAscending ? lhsDate < rhsDate : lhsDate > rhsDate
            }
        }
    }
}
