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
final class Recipe {
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
        title: String,
        desc: String,
        link: String,
        ingredients: [Ingredient],
        steps: [String],
        isFavorite: Bool = false,
        imageData: Data? = nil,
        category: String = "기타",
        remoteId: String? = nil,
        isShared: Bool = false
    ) {
        self.title = title
        self.desc = desc
        self.link = link
        self.ingredients = ingredients
        self.steps = steps
        self.isFavorite = isFavorite
        self.imageData = imageData
        self.createdAt = Date()
        self.category = category
        self.remoteId = remoteId
        self.isShared = isShared
    }
    
    // Firebase 데이터를 받아 Recipe 객체로 변환하는 함수
    static func fromFirebase(data: [String: Any], id: String) -> Recipe {
        let title = data["title"] as? String ?? ""
        let desc = data["desc"] as? String ?? ""
        let link = data["link"] as? String ?? ""
        let ingredients = data["ingredients"] as? [Ingredient] ?? []
        let steps = data["steps"] as? [String] ?? []
        let isFavorite = data["isFavorite"] as? Bool ?? false
        let category = data["category"] as? String ?? "기타"
        let isShared = data["isShared"] as? Bool ?? false
        
        // 이미지 데이터는 별도로 처리해야 함
        
        return Recipe(
            title: title,
            desc: desc,
            link: link,
            ingredients: ingredients,
            steps: steps,
            isFavorite: isFavorite,
            category: category,
            remoteId: id,
            isShared: isShared
        )
    }
    
    // Firebase에 저장하기 위한 딕셔너리 변환 함수
    func toFirebase() -> [String: Any] {
        return [
            "title": title,
            "desc": desc,
            "link": link,
            "ingredients": ingredients,
            "steps": steps,
            "isFavorite": isFavorite,
            "category": category,
            "createdAt": createdAt
            // 이미지는 별도로 Firebase Storage에 업로드해야 함
        ]
    }
}
