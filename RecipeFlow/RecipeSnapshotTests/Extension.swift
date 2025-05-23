//
//  Extension.swift
//  RecipeFlow
//
//  Created by Nitin George on 21/05/2025.
//


import SwiftUI
import UIKit

extension SwiftUI.View {
    func toVC() -> UIViewController {
        UIHostingController(rootView: self)
    }
}
