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
    
    //ToDo: fetch key from backend + fetch key after login success. Right now I just hardcoded the recipeAPI key and saved to keyChain
    private func fetchKeyFromBackend() async throws -> String {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let backendKey = "9223d79224msh6ad0e4f4ebb5b93p1d6f48jsn553047584145"

        return backendKey
    }
}
