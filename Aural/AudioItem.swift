struct AudioItem: Identifiable {
    let id = UUID()
    let url: URL
    var hasBeenPlayed: Bool = false
    var next: AudioItem?
    var prev: AudioItem?
}
