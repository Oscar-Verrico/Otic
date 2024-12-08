//
//  FileManagerHelper.swift
//  Aural
//
//  Created by Oscar Verrico on 12/6/24.
//


import Foundation

func createAppFolderIfNeeded() -> URL? {
    print("createAppFolderIfNeeded called")
    let fileManager = FileManager.default
    if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
        let appFolder = documentsDirectory.appendingPathComponent("MyAudioFiles")
        if !fileManager.fileExists(atPath: appFolder.path) {
            do {
                try fileManager.createDirectory(at: appFolder, withIntermediateDirectories: true, attributes: nil)
                print("App folder created at: \(appFolder.path)")
            } catch {
                print("Error creating app folder: \(error)")
                return nil
            }
        }
        return appFolder
    }
    return nil
}




func saveFileToAppFolder(_ fileURL: URL) {
    guard let appFolder = createAppFolderIfNeeded() else { return }

    let destinationURL = appFolder.appendingPathComponent(fileURL.lastPathComponent)
    let fileManager = FileManager.default

    do {
        if !fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.copyItem(at: fileURL, to: destinationURL)
            print("File saved to: \(destinationURL.path)")
        } else {
            print("File already exists at destination.")
        }
    } catch {
        print("Error saving file: \(error)")
    }
}

func getFilesInAppFolder() -> [URL] {
    guard let appFolder = createAppFolderIfNeeded() else { return [] }

    do {
        let fileURLs = try FileManager.default.contentsOfDirectory(at: appFolder, includingPropertiesForKeys: nil)
        return fileURLs
    } catch {
        print("Error reading files in folder: \(error)")
        return []
    }
}
