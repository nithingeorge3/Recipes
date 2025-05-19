//
//  PaginationSDServiceType.swift
//  RecipeDomain
//
//  Created by Nitin George on 19/05/2025.
//

import Foundation
import SwiftData

public protocol PaginationSDServiceType: Sendable {
    func fetchPagination(_ entityType: EntityType) async throws -> PaginationDomain
    func updatePagination(_ pagination: PaginationDomain) async throws
}
