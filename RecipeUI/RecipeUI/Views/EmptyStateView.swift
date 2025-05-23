//
//  EmptyStateView.swift
//  Recipes
//
//  Created by Nitin George on 02/03/2025.
//

import SwiftUI

public struct EmptyStateView: View {
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
    
    public var body: some View {
        Text(message)
            .multilineTextAlignment(.center)
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(.primary)
            .padding()
    }
}
