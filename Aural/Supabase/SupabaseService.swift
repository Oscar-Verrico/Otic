//
//  SupabaseService.swift
//  Aural
//
//  Created by Oscar Verrico on 12/10/24.
//

import Foundation
import Supabase

struct AnyEncodable: Encodable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let encodableValue = value as? Encodable {
            try encodableValue.encode(to: encoder)
        } else if let dictValue = value as? [String: Any] {
            try container.encode(dictValue.mapValues { AnyEncodable($0) })
        } else if let arrayValue = value as? [Any] {
            try container.encode(arrayValue.map { AnyEncodable($0) })
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Value cannot be encoded"))
        }
    }
}

class SupabaseService {
    static let shared = SupabaseService()

    private(set) var client: SupabaseClient!

    private init() {
        let supabaseURL = URL(string: "https://rjarzmrcvsmilxwjmnvy.supabase.co")!
        let supabaseKey = "YOUR_SUPABASE_API_KEY"
        client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }

    // Playlist Operations

    func fetchAllPlaylists(completion: @escaping (Result<[Playlist], Error>) -> Void) {
        Task {
            do {
                let response = try await client
                    .from("playlists")
                    .select("*")
                    .execute()

                let data = response.data
                let playlists = try JSONDecoder().decode([Playlist].self, from: data)
                completion(.success(playlists))
            } catch {
                completion(.failure(error))
            }
        }
    }



    func insertPlaylist(_ playlist: Playlist, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                let playlistData: [String: AnyEncodable] = [
                    "id": AnyEncodable(playlist.id.uuidString),
                    "name": AnyEncodable(playlist.name),
                    "default_thumbnail": AnyEncodable(playlist.defaultThumbnail),
                    "thumbnail": AnyEncodable(playlist.thumbnail?.base64EncodedString() ?? ""),
                    "date_added": AnyEncodable(ISO8601DateFormatter().string(from: playlist.dateAdded)),
                    "last_modified": AnyEncodable(ISO8601DateFormatter().string(from: playlist.lastModified))
                ]
                _ = try await client
                    .from("playlists")
                    .insert(playlistData)
                    .execute()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func deletePlaylist(byID playlistID: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                _ = try await client
                    .from("playlists")
                    .delete()
                    .eq("id", value: playlistID.uuidString)
                    .execute()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // Audio File Operations

    func fetchAudioFiles(forPlaylistID playlistID: UUID, completion: @escaping (Result<[AudioItem], Error>) -> Void) {
        Task {
            do {
                let response = try await client
                    .from("audio_files")
                    .select("*")
                    .eq("playlist_id", value: playlistID.uuidString)
                    .execute()

                let data = response.data
                let audioFiles = try JSONDecoder().decode([AudioItem].self, from: data)
                completion(.success(audioFiles))
            } catch {
                completion(.failure(error))
            }
        }
    }


    func insertAudioFiles(_ audioFiles: [AudioItem], intoPlaylistID playlistID: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        let fileData = audioFiles.map { audioFile in
            [
                "id": AnyEncodable(audioFile.id.uuidString),
                "playlist_id": AnyEncodable(playlistID.uuidString),
                "file_name": AnyEncodable(audioFile.url.lastPathComponent),
                "file_size": AnyEncodable(audioFile.fileSize),
                "duration": AnyEncodable(audioFile.duration ?? 0)
            ]
        }

        Task {
            do {
                _ = try await client
                    .from("audio_files")
                    .insert(fileData)
                    .execute()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func deleteAudioFile(byID fileID: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                _ = try await client
                    .from("audio_files")
                    .delete()
                    .eq("id", value: fileID.uuidString)
                    .execute()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// Helper Initializers for Decoding

extension Playlist {
    init?(dictionary: [String: Any]) {
        guard
            let idString = dictionary["id"] as? String,
            let id = UUID(uuidString: idString),
            let name = dictionary["name"] as? String,
            let defaultThumbnail = dictionary["default_thumbnail"] as? String,
            let dateAddedString = dictionary["date_added"] as? String,
            let lastModifiedString = dictionary["last_modified"] as? String,
            let dateAdded = ISO8601DateFormatter().date(from: dateAddedString),
            let lastModified = ISO8601DateFormatter().date(from: lastModifiedString)
        else {
            return nil
        }

        self.id = id
        self.name = name
        self.defaultThumbnail = defaultThumbnail
        self.thumbnail = (dictionary["thumbnail"] as? String).flatMap { Data(base64Encoded: $0) }
        self.dateAdded = dateAdded
        self.lastModified = lastModified
        self.audioFileIDs = []
    }
}

extension AudioItem {
    convenience init?(dictionary: [String: Any]) {
        guard
            let idString = dictionary["id"] as? String,
            let id = UUID(uuidString: idString),
            let fileName = dictionary["file_name"] as? String,
            let fileSize = dictionary["file_size"] as? Int
        else {
            return nil
        }

        // Initialize with the file path
        self.init(url: URL(fileURLWithPath: fileName))
        
        // Set additional properties
        self.fileSize = fileSize
        self.duration = dictionary["duration"] as? TimeInterval
    }
}
