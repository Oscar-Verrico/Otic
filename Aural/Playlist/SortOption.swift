// SortOption.swift
import Foundation

enum SortOption: String, CaseIterable, Identifiable {
    case name = "Name"
    case size = "Size"
    case fileType = "File Type"
    case tag = "Tag"
    case dateAdded = "Date Added"

    var id: String { self.rawValue }
}
