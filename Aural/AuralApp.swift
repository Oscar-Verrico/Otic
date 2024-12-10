//
//  AuralApp.swift
//  Aural
//
//  Created by Oscar Verrico on 11/4/24.
//

import SwiftUI
import Foundation

@main
struct AuralApp: App {
    init() {
        // Print the Documents Directory path
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            print("App Documents Directory: \(documentsURL.path)")
        } else {
            print("Could not locate the Documents directory.")
        }
    }
    @StateObject var playlistManager = PlaylistManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(playlistManager)
        }
    }
}
