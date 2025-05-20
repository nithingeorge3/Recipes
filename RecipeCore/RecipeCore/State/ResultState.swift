//
//  ResultState.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import Foundation

public enum ResultState: Equatable {
    case loading
    case failed(error: Error)
    case empty(message: String)
    case success
    
    static public func == (lhs: ResultState, rhs: ResultState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.success, .success):
            return true
        case (.empty, .empty):
            return true
        case (.failed, .failed):
            return true
        default:
            return false
        }
    }
}
