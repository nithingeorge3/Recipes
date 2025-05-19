//
//  TabBarVisibility.swift
//  Recipes
//
//  Created by Nitin George on 22/03/2025.
//

import Foundation
import Combine

@MainActor
public final class TabBarVisibility: ObservableObject {
    @Published public var isHidden: Bool = false
    
    public init(isHidden: Bool = false) {
        self.isHidden = isHidden
    }
}
