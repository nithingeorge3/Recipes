//
//  ErrorView.swift
//  Recipes
//
//  Created by Nitin George on 02/03/2025.
//

import SwiftUI

enum APIError: Error {
    case decodingError
    case errorCode(Int)
    case unknown
}

public typealias EmptyStateActionHandler = () -> Void

public struct ErrorView: View {
    public let handler: EmptyStateActionHandler
    public var error: Error
    
    public init(
        error: Error,
        handler: @escaping EmptyStateActionHandler) {
        self.error = error
        self.handler = handler
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.icloud.fill")
                .foregroundColor(.gray)
                .font(.system(size: 50, weight: .heavy))
            Text("Ooops...")
                .font(.system(size: 30, weight: .heavy))
            Text(error.localizedDescription)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
            Button("Retry") {
                handler()
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 10)
            .font(.system(size: 20, weight: .bold))
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

#if DEBUG
#Preview {
    ErrorView(error: APIError.decodingError, handler: {})
}
#endif
