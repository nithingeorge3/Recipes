//
//  SDPagination.swift
//  RecipeDataStore
//
//  Created by Nitin George on 04/03/2025.
//

import Foundation
import SwiftData
import RecipeDomain

#warning("please remove unwaned codes")
@Model
public class SDPagination {
    @Attribute(.unique)
    public var id: UUID
//    public var entityType: EntityType
    public var entityTypeRaw: Int
//    @Attribute(.transformable(by: EntityTypeTransformer.self)) // I need to use transformer, geeting carsh. Iwill check it later
//    public var entityType_: EntityType
    public var totalCount: Int
    public var currentPage: Int
    public var lastUpdated: Date
    
    public var entityType: EntityType {
        get { EntityType(rawValue: entityTypeRaw) ?? .recipe }
        set { entityTypeRaw = newValue.rawValue }
    }
    
    init(id: UUID = UUID(), type: EntityType, total: Int, page: Int, lastUpdated: Date = Date()) {
        self.id = id
//        self.entityType = type
        self.entityTypeRaw = type.rawValue
//        self.entityType_ = type
        self.totalCount = total
        self.currentPage = page
        self.lastUpdated = lastUpdated
    }
}

extension PaginationDomain {
    init(from sdPagination: SDPagination) {
        self.init(
            entityType: sdPagination.entityType,
            totalCount: sdPagination.totalCount,
            currentPage: sdPagination.currentPage,
            lastUpdated: sdPagination.lastUpdated
        )
    }
}

// Add ValueTransformer
//public final class EntityTypeTransformer: ValueTransformer {
//    public override func transformedValue(_ value: Any?) -> Any? {
//        guard let type = value as? EntityType else { return nil }
//        return type.rawValue
//    }
//    
//    public override func reverseTransformedValue(_ value: Any?) -> Any? {
//        guard let rawValue = value as? Int else { return nil }
//        return EntityType(rawValue: rawValue)
//    }
//    
//    public static override func allowsReverseTransformation() -> Bool { true }
//}
