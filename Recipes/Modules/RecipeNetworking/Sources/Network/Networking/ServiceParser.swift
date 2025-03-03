//
//  RecipeServiceParser.swift
//  RecipeNetworking
//
//  Created by Nitin George on 01/03/2024.
//

import Foundation

protocol ServiceParserType: Sendable {
    func parse<T: Decodable>(data: Data, response: URLResponse, type: T.Type) async throws -> T

}

final class ServiceParser: ServiceParserType {    
    func parse<T: Decodable>(data: Data, response: URLResponse, type: T.Type) async throws -> T {
        guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.responseError
        }
        
        do {
            let decoder = createDecoder()
            let decodedObject = try decoder.decode(T.self, from: data)
            return decodedObject
        } catch let decodingError {
            print("RecipeParser - Decoding error: \(decodingError)")
            throw NetworkError.failedToDecode
        } 
    }
    
    private func createDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
