
//
//  CustomBackButtonModifier.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI

struct CustomBackButtonModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    let action: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        action?() ?? dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
            }
    }
}

struct CustomNavigationTitle: ViewModifier {
    var title: String = "Recipe"
    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .foregroundColor(.primary)
                        .fontWeight(.semibold)
                }
            }
    }
}

extension View {
    public func withCustomBackButton(action: (() -> Void)? = nil) -> some View {
        modifier(CustomBackButtonModifier(action: action))
    }
    
    public func withCustomNavigationTitle(title: String) -> some View {
        modifier(CustomNavigationTitle(title: title))
    }
}
