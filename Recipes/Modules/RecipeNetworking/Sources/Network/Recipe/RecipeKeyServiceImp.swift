//
//  RecipeKeyService.swift
//  RecipeNetworking
//
//  Created by Nitin George on 01/03/2024.
//

import Foundation

final class RecipeKeyService: RecipeKeyServiceType {
    private let recipeKeyRepo: RecipeKeyRepositoryType
    //ToDo: inject later
    init(recipeKeyRepo: RecipeKeyRepositoryType = RecipeKeyRepository(keyChainManager: KeyChainManager.shared)) {
        self.recipeKeyRepo = recipeKeyRepo
    }
    
    func deleteRecipeAPIkey() -> Bool {
        return recipeKeyRepo.deleteRecipeAPIkey()
    }
}
