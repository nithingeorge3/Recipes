
//
//  RecipesViewModel.swift
//  Recipes
//
//  Created by Nitin George on 06/03/2025.
//

import Combine
import Foundation
import Observation
import RecipeNetworking
import RecipeDomain

@MainActor
public protocol RecipesViewModelType: AnyObject, Observable {
    var recipes: [Recipe] { get }
    var state: ResultState { get }
    
    func send(_ action: RecipeListAction)
}

//Actually we need only one viewmodel, as i am just showing listing with combine i used seperate viewmodel
@Observable
public class RecipesViewModel: RecipesViewModelType {
    public var state: ResultState = .loading
    public var recipes: [Recipe] = []
    public let service: RecipeListServiceType
    public var cancellables: Set<AnyCancellable> = []
    
    public init(service: RecipeListServiceType) {
        self.service = service
    }
    
    public func send(_ action: RecipeListAction) {
        switch action {
        case .refresh:
            Task { try await fetchRemoteRecipes() }
        default: break
        }
    }
    
    private func fetchRemoteRecipes() async throws {
        service.fetchRecipes(endPoint: .recipes(startIndex: 0, pageSize: 5))//hardcoded for listing
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    self.state = .success
                case .failure(let error):
                    self.state = .failed(error: error)
                }
            }
        receiveValue: { [weak self] response in
            self?.recipes.removeAll()
            self?.recipes = response.map { Recipe(from: $0) }
        }
        .store(in: &cancellables)
    }
    
    private func updateRecipes(with fetchedRecipes: [Recipe]) {
        if fetchedRecipes.count > 0 {
            recipes.append(contentsOf: fetchedRecipes)
        }
        
        state = .success
    }
}
