//
//  AudioBoxTests.swift
//  Aural
//
//  Created by Oscar Verrico on 12/6/24.
//


import XCTest
@testable import Aural

class AudioBoxTests: XCTestCase {
    var audioBox: AudioBox!

    override func setUp() {
        audioBox = AudioBox()
    }

    func testLoadAudioFile() {
        let testURL = URL(fileURLWithPath: "/path/to/audio.mp3")
        audioBox.loadAudioFile(from: testURL)
        XCTAssertNotNil(audioBox.audioPlayer)
    }

    func testPlayPauseStop() {
        audioBox.play()
        XCTAssertTrue(audioBox.isPlaying)

        audioBox.pause()
        XCTAssertFalse(audioBox.isPlaying)

        audioBox.stop()
        XCTAssertFalse(audioBox.isPlaying)
    }

    func testPlayNext() {
        let testPlaylist = [
            URL(fileURLWithPath: "/path/to/audio1.mp3"),
            URL(fileURLWithPath: "/path/to/audio2.mp3")
        ]
        audioBox.loadPlaylist(testPlaylist)
        audioBox.playNext()
        XCTAssertEqual(audioBox.currentTrack, testPlaylist[1])
    }
}
