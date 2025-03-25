//
//  TabBarVisibility.swift
//  Recipes
//
//  Created by Nitin George on 22/03/2025.
//

import Foundation

@MainActor
final class TabBarVisibility: ObservableObject {
    @Published var isHidden: Bool = false
}
