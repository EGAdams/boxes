//
//  DownloadProgressTracker.swift
//
//  Created by Clay Ackerland on 4/16/23.
//
import Foundation

class DownloadProgressTracker {

    // constructor
    init() {
        print( "initializing DownloadProgressTracker... " )
    }

    // A closure that will be called with the updated overall download progress (represented as a value between 0 and 1)
    var progressUpdateHandler: ((Double) -> Void)?
    
    // A dictionary that maps file identifiers to their respective download progress values
    private var fileDownloadProgress: [String: Double] = [:]
    
    // Update the progress of a file download with the given identifier
    // and notify the progressUpdateHandler with the updated overall download progress
    func updateProgress(forIdentifier identifier: String, progress: Double) {
        fileDownloadProgress[identifier] = progress
        reportOverallProgress()
    }
    
    // Reset the progress tracking by clearing the fileDownloadProgress dictionary
    func resetProgress() {
        fileDownloadProgress.removeAll()
    }
    
    // Calculate and report the overall download progress
    private func reportOverallProgress() {
        let totalProgress = fileDownloadProgress.values.reduce(0.0, +)
        let overallProgress = totalProgress / Double(fileDownloadProgress.count)
        progressUpdateHandler?(overallProgress)
    }
    
    func allFilesDownloaded() -> Bool {
        // Your logic to check if all files are downloaded
        print( "*** make sure to implement this.  i am just returning true to help compile. *** " )
        return true
    }
}

