//
//  CompletionHandlerManager.swift
//  boxes
//
//  Created by Clay Ackerland on 4/16/23.
//
import Foundation

typealias CompleteHandlerBlock = (URL?, URLResponse?, Error?) -> Void

class CompletionHandlerManager {
    private var completionHandlerQueue: [String: CompleteHandlerBlock] = [:]
    private let queue = DispatchQueue(label: "com.yourapp.CompletionHandlerManager")

    func addCompletionHandler(_ handler: @escaping CompleteHandlerBlock, forIdentifier identifier: String) {
        queue.sync {
            completionHandlerQueue[identifier] = handler
        }
    }

    func callCompletionHandler(forIdentifier identifier: String) {
        queue.sync {
            guard let completionHandler = completionHandlerQueue[identifier] else { return }
            completionHandlerQueue.removeValue(forKey: identifier)
            DispatchQueue.main.async {
                completionHandler(nil, nil, nil) // Pass the appropriate values as needed
            }
        }
    }

    func removeCompletionHandler(forIdentifier identifier: String) {
        queue.sync {
            completionHandlerQueue.removeValue(forKey: identifier)
            return // Add this line to suppress the warning
        }
    }
}
