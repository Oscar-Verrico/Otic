//
//  DocumentPicker.swift
//  Aural
//
//  Created by Oscar Verrico on 11/24/24.
//


import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    var completionHandler: (URL?) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.audio])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(completionHandler: completionHandler)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var completionHandler: (URL?) -> Void

        init(completionHandler: @escaping (URL?) -> Void) {
            self.completionHandler = completionHandler
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            completionHandler(urls.first)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            completionHandler(nil)
        }
    }
}

