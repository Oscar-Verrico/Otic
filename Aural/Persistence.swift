//
//  Persistence.swift
//  Aural
//
//  Created by Oscar Verrico on 11/4/24.
//

import CoreData

class Persistence {
    static let shared = Persistence()
    let fileManager = FileManager.default
    
    func saveAudioFile(url: URL, data: Data) {
        let documentsURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let destinationURL = documentsURL.appendingPathComponent(url.lastPathComponent)
        do {
            try data.write(to: destinationURL)
        } catch {
            print("Error saving audio file: \(error.localizedDescription)")
        }
    }
    
    func deleteAudioFile(url: URL) {
        do {
            try fileManager.removeItem(at: url)
        } catch {
            print("Error deleting audio file: \(error.localizedDescription)")
        }
    }
} 
