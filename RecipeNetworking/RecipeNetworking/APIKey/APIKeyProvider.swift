//
//  APIKeyProvider.swift
//  ArecipeNetworking
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation

protocol APIKeyProviderType: Sendable {
    func getRecipeAPIKey() async throws -> String
    func saveRecipeAPIKey(_ key: String)
}

final class APIKeyProvider: APIKeyProviderType {
    private let keyChainManager: KeyChainManagerType
    
    init(keyChainManager: KeyChainManagerType = KeyChainManager.shared) {
        self.keyChainManager = keyChainManager
    }
    
    func getRecipeAPIKey() async throws -> String {
        if let savedKey = keyChainManager.recipeAPIKey() {
            return savedKey
        }
        
        let newKey =  try await fetchKeyFromBackend()
        
        saveRecipeAPIKey(newKey)
        
        return newKey
    }
    
    func saveRecipeAPIKey(_ key: String) {
        keyChainManager.saveRecipeAPIKey(key)
    }
    
    /// ToDo:
    /// - Fetch API key securely from backend after login success
    /// - Remove hardcoded fallback key
    /// - Save key to Keychain after retrieval
    ///
    /// Note:
    /// If the current key has reached its usage limit,
    /// you can temporarily use: "479405c3e3mshd17f0038daa3acap1aa647jsnc7a49c1e2e93"
    private func fetchKeyFromBackend() async throws -> String {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let backendKey = "53053d2c99msha938f9283114fdep1f1931jsn24fc750558f7"

        return backendKey
    }
}
