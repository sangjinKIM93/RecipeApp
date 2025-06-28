//
//  ReceipeDetail.swift
//  RecipeApp
//
//  Created by 김상진 on 5/17/25.
//

import SwiftUI

// MARK: - 레시피 상세 뷰
struct RecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var recipe: Recipe
    @State private var showEditSheet = false
    @State private var needEdit: Bool
    
    init(recipe: Recipe, needEdit: Bool = false) {
        self.recipe = recipe
        self.needEdit = needEdit
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 이미지
                if let imageData = recipe.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
                
                VStack(alignment: .leading, spacing: 24) {
                    // 제목 및 설명
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(recipe.title)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                recipe.isFavorite.toggle()
                            }) {
                                Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                                    .font(.title2)
                                    .foregroundColor(recipe.isFavorite ? .red : .gray)
                            }
                        }
                        
                        Text(recipe.category)
                            .font(.subheadline)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                        
                        Text(recipe.desc)
                            .padding(.top, 4)
                        
                        Text(recipe.link)
                            .padding(.top, 4)
                    }
                    
                    // 재료
                    VStack(alignment: .leading, spacing: 10) {
                        Text("재료")
                            .font(.headline)
                        
                        ForEach(recipe.ingredients, id: \.self) { ingredient in
                            HStack(alignment: .top) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 8))
                                    .padding(.top, 6)
                                // TODO: 합친거로 수정
                                Text("\(ingredient.name) \(ingredient.number)\(ingredient.scale)")
                            }
                        }
                    }
                    
                    // 조리 단계
                    VStack(alignment: .leading, spacing: 10) {
                        Text("조리 단계")
                            .font(.headline)
                        
                        ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top) {
                                Text("\(index + 1)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Circle().fill(Color.blue))
                                
                                Text(step)
                                    .padding(.leading, 4)
                            }
                            .padding(.bottom, 4)
                        }
                    }
                    
                    HStack {
                        Image(systemName: recipe.isShared ? "person.2.fill" : "person.2")
                        Text(recipe.isShared ? "공유됨" : "비공개")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(recipe.isShared ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                    .foregroundColor(recipe.isShared ? .green : .gray)
                    .cornerRadius(4)
                }
                .padding()
            }
        }
        .navigationTitle("레시피 상세")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if needEdit {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("편집") {
                        showEditSheet = true
                    }
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditRecipeView(recipe: recipe)
        }
    }
}
