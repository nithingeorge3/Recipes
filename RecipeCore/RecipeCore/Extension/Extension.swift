//
//  Extension.swift
//  Recipes
//
//  Created by Nitin George on 02/03/2025.
//

//import Foundation
//import SwiftUICore
//
//extension String? {
//    var validatedURL: URL? {
//        guard let self = self else { return nil }
//        return URL(string: self)
//    }
//}
//
//extension DateFormatter {
//    static let recipeDateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .long
//        formatter.timeStyle = .none
//        formatter.doesRelativeDateFormatting = true
//        return formatter
//    }()
//    
//    static func relativeDateString(from timestamp: Int?) -> String? {
//        guard let timestamp = timestamp else { return nil }
//        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
//        return DateFormatter.recipeDateFormatter.string(from: date)
//    }
//}
//
//extension View {
//    func navigationAccessibility(title: String) -> some View {
//        self
//            .navigationTitle(title)
//            .accessibilityElement(children: .ignore)
//            .accessibilityLabel(title)
//            .accessibilityAddTraits(.isHeader)
//    }
//}
