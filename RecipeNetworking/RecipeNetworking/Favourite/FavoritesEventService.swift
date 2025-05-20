//
//  FavoritesEventServiceType.swift
//  RecipeNetworking
//
//  Created by Nitin George on 20/05/2025.
//

import Combine

public protocol FavoritesEventServiceType: Sendable {
    var favoriteDidChange: PassthroughSubject<Int, Never> { get }
}

public final class FavoritesEventService: FavoritesEventServiceType, @unchecked Sendable {
    public init(){ }
    
    public let favoriteDidChange = PassthroughSubject<Int, Never>()
}
