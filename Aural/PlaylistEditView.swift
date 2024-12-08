import SwiftUI

struct PlaylistEditView: View {
    @ObservedObject var playlistManager: PlaylistManager
    var playlist: Playlist
    @State private var newName: String
    @State private var newThumbnail: String

    init(playlistManager: PlaylistManager, playlist: Playlist) {
        self.playlistManager = playlistManager
        self.playlist = playlist
        _newName = State(initialValue: playlist.name)
        _newThumbnail = State(initialValue: playlist.thumbnail)
    }

    var body: some View {
        VStack {
            // Playlist Name Editor
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

            // Playlist Thumbnail Editor
            HStack {
                TextField("Thumbnail Icon", text: $newThumbnail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Save") {
                    if let index = playlistManager.playlists.firstIndex(where: { $0.id == playlist.id }) {
                        playlistManager.playlists[index].thumbnail = newThumbnail
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()

            // Display and Edit Playlist Items
            List {
                ForEach(playlist.audioItems, id: \.self) { item in
                    HStack {
                        Text(item.url.lastPathComponent)
                        Spacer()
                        Button(action: {
                            if let playlistIndex = playlistManager.playlists.firstIndex(where: { $0.id == playlist.id }),
                               let itemIndex = playlistManager.playlists[playlistIndex].audioItems.firstIndex(of: item) {
                                playlistManager.playlists[playlistIndex].audioItems.remove(at: itemIndex)
                            }
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .navigationTitle("Edit Playlist")
    }
}
