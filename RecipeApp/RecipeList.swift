//
//  RecipeList.swift
//  RecipeApp
//
//  Created by 김상진 on 5/17/25.
//

import SwiftUI
import SwiftData

// MARK: - 레시피 목록 뷰
struct RecipeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.title) private var recipes: [Recipe]
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
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(categories, id: \.self) { category in
                        CategoryButton(
                            title: category,
                            isSelected: category == selectedCategory || (category == "모두" && selectedCategory == nil),
                            action: {
                                if category == "모두" {
                                    selectedCategory = nil
                                } else {
                                    selectedCategory = category
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            // 레시피 목록
            List {
                ForEach(filteredRecipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        RecipeRow(recipe: recipe)
                    }
                }
                .onDelete(perform: deleteRecipes)
            }
            .listStyle(.inset)
        }
        .searchable(text: $searchText, prompt: "레시피 검색")
    }
    
    private func deleteRecipes(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredRecipes[index])
        }
    }
}

// MARK: - 카테고리 버튼
struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - 레시피 행
struct RecipeRow: View {
    let recipe: Recipe
    
    var body: some View {
        HStack {
            if let imageData = recipe.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .cornerRadius(8)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(width: 70, height: 70)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.headline)
                
                HStack {
                    Label("\(recipe.prepTime + recipe.cookTime)분", systemImage: "clock")
                        .font(.caption)
                    
                    Spacer()
                    
                    if recipe.isFavorite {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    }
                    
                    if recipe.isShared {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                Text(recipe.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
}
