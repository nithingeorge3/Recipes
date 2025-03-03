//
//  RequestBuilder.swift
//  RecipeNetworking
//
//  Created by Nitin George on 01/03/2024.
//

import Foundation

protocol RequestBuilderType: Sendable {
    func buildRequest(url: URL, apiKey: String?) -> URLRequest
}

final class RequestBuilder: RequestBuilderType {
    func buildRequest(url: URL, apiKey: String? = nil) -> URLRequest {
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json",
                         forHTTPHeaderField: "Content-Type")
        request.addValue("tasty.p.rapidapi.com",
                         forHTTPHeaderField: "x-rapidapi-host")
        if let apiKey = apiKey {
            request.addValue(apiKey,
                             forHTTPHeaderField: "x-rapidapi-key")
        }
        print(request)
        return request
    }
}
//https://tasty.p.rapidapi.com/recipes/list?from=0&size=20&tags=under_30_minutes
//request.httpMethod = "GET"
//request.allHTTPHeaderFields = ["x-rapidapi-key": "9223d79224msh6ad0e4f4ebb5b93p1d6f48jsn553047584145", "x-rapidapi-host": "tasty.p.rapidapi.com"]

