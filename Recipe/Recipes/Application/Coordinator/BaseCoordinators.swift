//
//  BaseCoordinators.swift
//  Recipes
//
//  Created by Nitin George on 02/03/2025.
//

import SwiftUI

@MainActor
protocol Coordinator {
    associatedtype ContentViewType: View
    func start() -> ContentViewType
}
