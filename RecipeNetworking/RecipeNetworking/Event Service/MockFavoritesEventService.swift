//
//  MockFavoritesEventService.swift
//  RecipeNetworking
//
//  Created by Nitin George on 21/05/2025.
//

import Combine

public final class MockFavoritesEventService: FavoritesEventServiceType,  @unchecked Sendable {
    public let favoriteDidChange: PassthroughSubject<Int, Never>
    
    public private(set) var receivedEvents: [Int] = []
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        self.favoriteDidChange = PassthroughSubject<Int, Never>()
        
        favoriteDidChange
            .sink { [weak self] event in
                self?.receivedEvents.append(event)
            }
            .store(in: &cancellables)
    }
    
    public func simulateFavoriteChange(_ recipeId: Int) {
        favoriteDidChange.send(recipeId)
    }
}
