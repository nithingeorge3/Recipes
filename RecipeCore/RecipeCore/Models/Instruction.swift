//
//  Instruction.swift
//  Recipes
//
//  Created by Nitin George on 02/03/2025.
//

import Foundation
import RecipeDomain

public struct Instruction: Identifiable, Hashable {
    public let id: Int
    public var position: Int
    public var description: String?
    public var startTime: Int
    public var endTime: Int
    
    public init(id: Int, position: Int, description: String? = nil, startTime: Int, endTime: Int) {
        self.id = id
        self.position = position
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Instruction, rhs: Instruction) -> Bool {
        lhs.id == rhs.id
    }
}
