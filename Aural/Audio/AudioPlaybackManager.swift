//
//  AudioPlaybackManager.swift
//  Aural
//
//  Created by Oscar Verrico on 12/9/24.
//

import Foundation
import AVFoundation

class AudioPlaybackManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = AudioPlaybackManager() // Singleton instance

    @Published var isPlaying: Bool = false
    @Published var currentTrackIndex: Int = 0
    @Published var isLoopEnabled: Bool = false {
        didSet {
            objectWillChange.send()
        }
    }
    @Published var isShuffleEnabled: Bool = false {
        didSet {
            shufflePlaylist()
        }
    }

    private var audioPlayer: AVAudioPlayer?
    private(set) var playlist: [AudioItem] = []
    private var originalPlaylist: [AudioItem] = [] // Keep the original order for resetting shuffle
    @Published var audioFiles: [AudioItem] = [] // Centralized list of all audio files

    private override init() {
        super.init()
    }

    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio session configured successfully.")
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    func playPlaylist(_ playlist: [AudioItem]) {
        guard !playlist.isEmpty else { return }

        self.originalPlaylist = playlist
        self.playlist = isShuffleEnabled ? playlist.shuffled() : playlist

        if isPlaying {
            stopPlayback()
        } else {
            currentTrackIndex = 0
            playCurrentTrack()
        }
    }

    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
    }

    private func playCurrentTrack() {
        guard currentTrackIndex < playlist.count else {
            if isLoopEnabled {
                currentTrackIndex = 0
                playCurrentTrack()
            } else {
                stopPlayback()
            }
            return
        }

        let trackURL = playlist[currentTrackIndex].url
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: trackURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }

    func playAudioFile(_ url: URL) {
        configureAudioSession()

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }

    private func shufflePlaylist() {
        if isShuffleEnabled {
            playlist.shuffle()
        } else {
            playlist = originalPlaylist
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        currentTrackIndex += 1
        playCurrentTrack()
    }
    
    func getAudioItem(by id: UUID) -> AudioItem? {
            return audioFiles.first { $0.id == id }
        }
}
