//
//  PlaylistManagerTests.swift
//  Aural
//
//  Created by Oscar Verrico on 12/6/24.
//


import XCTest
@testable import Aural

class PlaylistManagerTests: XCTestCase {
    var manager: PlaylistManager!

    override func setUp() {
        manager = PlaylistManager()
    }

    func testCreateAndDeletePlaylist() {
        manager.createPlaylist(name: "Test Playlist", thumbnail: "test.image")
        XCTAssertEqual(manager.playlists.count, 1)

        let playlistID = manager.playlists[0].id
        manager.deletePlaylist(playlistID)
        XCTAssertTrue(manager.playlists.isEmpty)
    }

    func testAddAudioItem() {
        manager.createPlaylist(name: "Test Playlist", thumbnail: "test.image")
        let playlistID = manager.playlists[0].id

        let testItem = AudioItem(url: URL(fileURLWithPath: "/path/to/audio.mp3"))
        manager.addAudioItem(to: playlistID, item: testItem)

        XCTAssertEqual(manager.playlists[0].audioItems.count, 1)
    }
}
