//
//  RecipeDTO.swift
//  RecipeNetworking
//
//  Created by Nitin George on 01/03/2024.
//

import Foundation

struct RecipeResponseDTO: Codable {
    let count: Int
    let results: [RecipeDTO]
}

struct RecipeDTO: Codable {
    let id: Int
    let name: String
    let country: Country?
    let description: String?
    let thumbnailURL: String?
    let originalVideoURL: String?
    let createdAt, approvedAt: Int?
    let yields: String?
//    let tags: [TagDTO]
    let userRatings: UserRatingsDTO?
//    let instructions: [InstructionDTO]
//    let language: Language

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case country
        case description
        case thumbnailURL = "thumbnail_url"
        case originalVideoURL = "original_video_url"
        case createdAt = "created_at"
        case approvedAt = "approved_at"
        case yields
//        case tags
        case userRatings = "user_ratings"
//        case instructions
//        case language
    }
}

enum Country: String, Codable {
    case us = "US"
    case unknown
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Country(rawValue: rawValue) ?? .unknown
    }
}
/*
 struct Country: Hashable, Codable {
     let code: String
     
     var localizedName: String? {
         Locale.current.localizedString(forRegionCode: code)
     }
     
     private static let recognizedCodes: Set<String> = [
         "US", "GB", "CA", "FR", "DE", "IT", "JP", "KR", "IN", "BR"
     ]
     
     var isRecognized: Bool {
         Self.recognizedCodes.contains(code)
     }
     
     init(code: String) {
         self.code = code.uppercased()
     }
     
     init(from decoder: Decoder) throws {
         let container = try decoder.singleValueContainer()
         let rawValue = try container.decode(String.self)
         self.init(code: rawValue)
     }
     
     func encode(to encoder: Encoder) throws {
         var container = encoder.singleValueContainer()
         try container.encode(code)
     }
     
     static let unitedStates = Country(code: "US")
     static let unitedKingdom = Country(code: "GB")
     static let canada = Country(code: "CA")
     static let france = Country(code: "FR")
     static let germany = Country(code: "DE")
 }
 */

struct InstructionDTO: Codable {
    let startTime: Int
    let appliance: String?
    let endTime: Int
    let temperature: Int?
    let id, position: Int
    let displayText: String

    enum CodingKeys: String, CodingKey {
        case startTime = "start_time"
        case appliance
        case endTime = "end_time"
        case temperature, id, position
        case displayText = "display_text"
    }
}

struct IngredientDTO: Codable {
    let displayPlural: String
    let id: Int
    let displaySingular: String
    let updatedAt: Int
    let name: String
    let createdAt: Int

    enum CodingKeys: String, CodingKey {
        case displayPlural = "display_plural"
        case id
        case displaySingular = "display_singular"
        case updatedAt = "updated_at"
        case name
        case createdAt = "created_at"
    }
}

struct TagDTO: Codable {
    let name: String
    let id: Int
    let displayName: String
    let type: TagTypeDTO

    enum CodingKeys: String, CodingKey {
        case name, id
        case displayName = "display_name"
        case type
    }
}

enum TagTypeDTO: String, Codable {
    case appliance = "appliance"
    case cuisine = "cuisine"
    case dietary = "dietary"
    case difficulty = "difficulty"
    case dishStyle = "dish_style"
    case equipment = "equipment"
    case featurePage = "feature_page"
    case holiday = "holiday"
    case meal = "meal"
    case method = "method"
    case occasion = "occasion"
    case seasonal = "seasonal"
}

struct UserRatingsDTO: Codable {
    let countNegative, countPositive: Int?
    let score: Double?

    enum CodingKeys: String, CodingKey {
        case countNegative = "count_negative"
        case countPositive = "count_positive"
        case score
    }
}
