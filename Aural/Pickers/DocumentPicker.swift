//
//  DocumentPicker.swift
//  Aural
//
//  Created by Oscar Verrico on 11/24/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    var onPicked: (URL?) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.audio])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPicked: onPicked)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var onPicked: (URL?) -> Void

        init(onPicked: @escaping (URL?) -> Void) {
            self.onPicked = onPicked
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            print("Picked URLs: \(urls)")
            controller.dismiss(animated: true, completion: nil)
            DispatchQueue.main.async {
                self.onPicked(urls.first)
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            controller.dismiss(animated: true, completion: nil) // Explicitly dismiss
            DispatchQueue.main.async {
                self.onPicked(nil)
            }
        }
    }
}
