//
//  UserRatings.swift
//  Recipes
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation
import RecipeDomain

struct UserRatings: Identifiable, Hashable {
    let id: Int?
    let countNegative, countPositive: Int
    let score: Double
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: UserRatings, rhs: UserRatings) -> Bool {
        lhs.id == rhs.id
    }
    
    init(id: Int, countNegative: Int = 0, countPositive: Int = 0, score: Double = 0) {
        self.id = id
        self.countNegative = countNegative
        self.countPositive = countPositive
        self.score = score
    }
}

extension UserRatings {
    init(from userRatingsDomain: UserRatingsDomain?) {
        self.id = userRatingsDomain?.id
        self.countNegative = userRatingsDomain?.countNegative ?? 0
        self.countPositive = userRatingsDomain?.countPositive ?? 0
        self.score = userRatingsDomain?.score ?? 0
    }
}
