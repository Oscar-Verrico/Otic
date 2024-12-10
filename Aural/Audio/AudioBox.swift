//
//  AudioBox.swift
//  Aural
//
//  Created by Brynn Lavender on 11/10/24.
//
// Updated AudioBox.swift

import SwiftUI
import AVFoundation

class AudioBox: NSObject, ObservableObject, AVAudioPlayerDelegate {
    var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var currentTrack: URL?
    var playlist: [URL] = []
    var currentIndex: Int = 0

    func loadPlaylist(_ files: [URL]) {
        playlist = files
        currentIndex = 0
        loadAudioFile(from: playlist[currentIndex])
    }

    func loadAudioFile(from url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            currentTrack = url
        } catch {
            print("Error loading audio file: \(error.localizedDescription)")
        }
    }

    func play() {
        audioPlayer?.play()
        isPlaying = true
    }

    func pause() {
        audioPlayer?.pause()
        isPlaying = false
    }

    func stop() {
        audioPlayer?.stop()
        isPlaying = false
        audioPlayer?.currentTime = 0
    }

    func playNext() {
        guard currentIndex < playlist.count - 1 else { return }
        currentIndex += 1
        loadAudioFile(from: playlist[currentIndex])
        play()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playNext()
    }
}
