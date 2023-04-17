//
//  FileHandler.swift
//
//  Created by Clay Ackerland on 4/16/23
//
import Foundation

class FileHandler {
    // Save a file from a remote URL to a local URL.
    func saveFile(from remoteURL: URL, to localURL: URL) throws {
        let data = try Data(contentsOf: remoteURL)
        try data.write(to: localURL)
    }

    // Delete a file at the specified local URL.
    func deleteFile(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }

    // Generate a local file URL based on the given remote URL and directory path.
    func localFileURL(for remoteURL: URL, in directory: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let localDirectoryURL = documentsURL.appendingPathComponent(directory)
        
        if !fileManager.fileExists(atPath: localDirectoryURL.path) {
            do {
                try fileManager.createDirectory(at: localDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating directory: \(error.localizedDescription)")
                return nil
            }
        }
        
        let localURL = localDirectoryURL.appendingPathComponent(remoteURL.lastPathComponent)
        return fileManager.fileExists(atPath: localURL.path) ? localURL : nil
    }
}
