//
//  AudioItem.swift
//  Aural
//
//  Created by Oscar Verrico on 12/4/24.
//

import Foundation

class AudioItem: Identifiable, Equatable, Hashable {
    let id = UUID()
    let url: URL
    var hasBeenPlayed: Bool = false
    weak var next: AudioItem? = nil
    weak var prev: AudioItem? = nil

    init(url: URL) {
        self.url = url
    }

    static func == (lhs: AudioItem, rhs: AudioItem) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

