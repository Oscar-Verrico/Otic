//
//  SortingUtility.swift
//  Aural
//
//  Created by Oscar Verrico on 12/6/24.
//

import Foundation

class SortingUtility {
    static func sortFiles(_ files: [URL], by option: SortOption, ascending: Bool, playlistManager: PlaylistManager) -> [URL] {
        switch option {
        case .name:
            return files.sorted { ascending ? $0.lastPathComponent < $1.lastPathComponent : $0.lastPathComponent > $1.lastPathComponent }
        case .size:
            return files.sorted {
                let lhsSize = (try? $0.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                let rhsSize = (try? $1.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                return ascending ? lhsSize < rhsSize : lhsSize > rhsSize
            }
        case .fileType:
            return files.sorted { ascending ? $0.pathExtension < $1.pathExtension : $0.pathExtension > $1.pathExtension }
        case .tag:
            return files.sorted {
                let lhsTag = playlistManager.fileTags[$0] ?? 0
                let rhsTag = playlistManager.fileTags[$1] ?? 0
                return ascending ? lhsTag < rhsTag : lhsTag > rhsTag
            }
        case .dateAdded:
            return files.sorted {
                let lhsDate = (try? $0.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                let rhsDate = (try? $1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                return ascending ? lhsDate < rhsDate : lhsDate > rhsDate
            }
        }
    }
}
