//
//  Extension.swift
//  Recipes
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation

extension Optional where Wrapped == String {
    var validatedURL: URL? {
        guard let string = self, !string.isEmpty else { return nil }
        return URL(string: string)
    }
}
