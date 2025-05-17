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
    var ingredients: [String]
    var steps: [String]
    var prepTime: Int // 준비 시간(분)
    var cookTime: Int // 조리 시간(분)
    var servings: Int // 몇 인분
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
        ingredients: [String],
        steps: [String],
        prepTime: Int,
        cookTime: Int,
        servings: Int,
        isFavorite: Bool = false,
        imageData: Data? = nil,
        category: String = "기타",
        remoteId: String? = nil,
        isShared: Bool = false
    ) {
        self.title = title
        self.desc = desc
        self.ingredients = ingredients
        self.steps = steps
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.servings = servings
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
        let ingredients = data["ingredients"] as? [String] ?? []
        let steps = data["steps"] as? [String] ?? []
        let prepTime = data["prepTime"] as? Int ?? 0
        let cookTime = data["cookTime"] as? Int ?? 0
        let servings = data["servings"] as? Int ?? 1
        let isFavorite = data["isFavorite"] as? Bool ?? false
        let category = data["category"] as? String ?? "기타"
        let isShared = data["isShared"] as? Bool ?? false
        
        // 이미지 데이터는 별도로 처리해야 함
        
        return Recipe(
            title: title,
            desc: desc,
            ingredients: ingredients,
            steps: steps,
            prepTime: prepTime,
            cookTime: cookTime,
            servings: servings,
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
            "ingredients": ingredients,
            "steps": steps,
            "prepTime": prepTime,
            "cookTime": cookTime,
            "servings": servings,
            "isFavorite": isFavorite,
            "category": category,
            "createdAt": createdAt
            // 이미지는 별도로 Firebase Storage에 업로드해야 함
        ]
    }
}
