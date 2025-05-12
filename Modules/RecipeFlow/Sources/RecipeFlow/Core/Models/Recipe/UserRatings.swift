//
//  UserRatings.swift
//  Recipes
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation
import RecipeDomain

public struct UserRatings: Identifiable, Hashable {
    public let id: Int?
    public let countNegative, countPositive: Int
    public let score: Double
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: UserRatings, rhs: UserRatings) -> Bool {
        lhs.id == rhs.id
    }
    
    public init(id: Int, countNegative: Int = 0, countPositive: Int = 0, score: Double = 0) {
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
