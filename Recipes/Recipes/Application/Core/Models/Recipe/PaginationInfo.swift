//
//  PaginationInfo.swift
//  Recipes
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation
import RecipeDomain

struct PaginationInfo: Identifiable, Hashable {
    let id: Int
    let totalCount: Int
    var currentPage: Int
    let lastUpdated: Date
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: PaginationInfo, rhs: PaginationInfo) -> Bool {
        lhs.id == rhs.id
    }
}
