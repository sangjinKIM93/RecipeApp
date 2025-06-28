//
//  Item.swift
//  RecipeApp
//
//  Created by 김상진 on 5/17/25.
//

import Foundation
import SwiftData

// MARK: - 모델
@Model
final class Recipe: Codable {
    var id: String
    var title: String
    var desc: String
    var link: String
    var ingredients: [Ingredient]
    var steps: [String]
    var isFavorite: Bool
    var imageData: Data? // 이미지 데이터
    var createdAt: Date
    var category: String
    var isShared: Bool
    
    // 나중에 Firebase 연동을 위한 ID
    var remoteId: String?
    
    init(
        id: String = UUID().uuidString,
        title: String,
        desc: String,
        link: String,
        ingredients: [Ingredient],
        steps: [String],
        isFavorite: Bool = false,
        imageData: Data? = nil,
        category: String = "기타",
        isShared: Bool = false,
        remoteId: String? = nil
    ) {
        self.id = id
        self.title = title
        self.desc = desc
        self.link = link
        self.ingredients = ingredients
        self.steps = steps
        self.isFavorite = isFavorite
        self.imageData = imageData
        self.createdAt = Date()
        self.category = category
        self.isShared = isShared
        self.remoteId = remoteId
    }
    
    // Firebase 데이터를 받아 Recipe 객체로 변환하는 함수
    static func fromFirebase(data: [String: Any], id: String) -> Recipe {
        let id = data["id"] as? String ?? ""
        let title = data["title"] as? String ?? ""
        let desc = data["desc"] as? String ?? ""
        let link = data["link"] as? String ?? ""
        let ingredientsData = data["ingredients"] as? [[String: Any]] ?? []
        let steps = data["steps"] as? [String] ?? []
        let isFavorite = data["isFavorite"] as? Bool ?? false
        let category = data["category"] as? String ?? "기타"
        let isShared = data["isShared"] as? Bool ?? false
        let remoteId = data["remoteId"] as? String ?? ""
        
        let ingredients = ingredientsData.compactMap { Ingredient.fromFirebase($0) }

        // 이미지 데이터는 별도로 처리해야 함
        
        
        return Recipe(
            id: id,
            title: title,
            desc: desc,
            link: link,
            ingredients: ingredients,
            steps: steps,
            isFavorite: isFavorite,
            category: category,
            isShared: isShared,
            remoteId: remoteId
        )
    }
    
    // Firebase에 저장하기 위한 딕셔너리 변환 함수
    func toFirebase() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "desc": desc,
            "link": link,
            "ingredients": ingredients.map { $0.toFirebase() },
            "steps": steps,
            "isFavorite": isFavorite,
            "category": category,
            "createdAt": createdAt,
            "isShared": isShared,
            "remoteId": remoteId
            // 이미지는 별도로 Firebase Storage에 업로드해야 함
        ]
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case desc
        case link
        case ingredients
        case steps
        case isFavorite
        case imageData
        case createdAt
        case category
        case isShared
        case remoteId
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.desc = try container.decode(String.self, forKey: .desc)
        self.link = try container.decode(String.self, forKey: .link)
        self.ingredients = try container.decode([Ingredient].self, forKey: .ingredients)
        self.steps = try container.decode([String].self, forKey: .steps)
        self.isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        self.imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.category = try container.decode(String.self, forKey: .category)
        self.isShared = try container.decode(Bool.self, forKey: .isShared)
        self.remoteId = try container.decodeIfPresent(String.self, forKey: .remoteId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(desc, forKey: .desc)
        try container.encode(link, forKey: .link)
        try container.encode(ingredients, forKey: .ingredients)
        try container.encode(steps, forKey: .steps)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encodeIfPresent(imageData, forKey: .imageData)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(category, forKey: .category)
        try container.encode(isShared, forKey: .isShared)
        try container.encode(remoteId, forKey: .remoteId)
    }
}
