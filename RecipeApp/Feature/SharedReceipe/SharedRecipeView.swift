//
//  SharedRecipeView.swift
//  RecipeApp
//
//  Created by 김상진 on 6/28/25.
//

import SwiftUI
import SwiftData

// MARK: - 레시피 목록 뷰
struct SharedRecipeView: View {
    @State var recipes: [Recipe] = []
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    
    var categories: [String] {
        var uniqueCategories = Set(recipes.map { $0.category })
        uniqueCategories.insert("모두")
        return Array(uniqueCategories).sorted()
    }
    
    var filteredRecipes: [Recipe] {
        var filtered = recipes
        
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        if let category = selectedCategory, category != "모두" {
            filtered = filtered.filter { $0.category == category }
        }
        
        return filtered
    }
    
    var body: some View {
        VStack {
            // 카테고리 필터
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack {
//                    ForEach(categories, id: \.self) { category in
//                        CategoryButton(
//                            title: category,
//                            isSelected: category == selectedCategory || (category == "모두" && selectedCategory == nil),
//                            action: {
//                                if category == "모두" {
//                                    selectedCategory = nil
//                                } else {
//                                    selectedCategory = category
//                                }
//                            }
//                        )
//                    }
//                }
//                .padding(.horizontal)
//            }
//            .padding(.vertical, 8)
            
            // 레시피 목록
            List {
                ForEach(filteredRecipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        RecipeRow(recipe: recipe)
                    }
                }
            }
            .listStyle(.inset)
        }
//        .searchable(text: $searchText, prompt: "레시피 검색")
        .task {
            do {
                recipes = try await FirestoreManager().getAllRecipes()
            } catch {
                print("fireStore load fail~!~!")
            }
        }
    }
}
