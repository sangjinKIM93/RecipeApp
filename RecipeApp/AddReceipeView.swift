//
//  AddReceipeView.swift
//  RecipeApp
//
//  Created by 김상진 on 5/17/25.
//

import SwiftUI
import SwiftData

@Model
final class Ingredient {
    var name: String
    var number: Int
    var scale: String = "스푼"
    
    init(name: String = "", number: Int = 0, scale: String = "스푼") {
        self.name = name
        self.number = number
        self.scale = scale
    }
}

// MARK: - 레시피 추가 뷰
struct AddRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var desc = ""
    @State private var link = ""
    @State private var ingredients: [Ingredient] = [Ingredient(name: "", number: 0, scale: "")]
    @State private var steps = [""]
    @State private var category = "메인 요리"
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var isShared = false
    
    let categories = ["메인 요리", "초간단", "간식", "디저트", "샐러드", "기타"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("기본 정보")) {
                    TextField("레시피 이름", text: $title)
                    
                    Picker("카테고리", selection: $category) {
                        ForEach(categories, id: \.self) {
                            Text($0)
                        }
                    }
                    
                    TextField("설명", text: $desc, axis: .vertical)
                        .lineLimit(3...6)
                    
                    TextField("링크", text: $link, axis: .vertical)
                }
                
                Section(header: Text("이미지")) {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        HStack {
                            Text("이미지 선택")
                            Spacer()
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Image(systemName: "photo")
                                    .font(.title)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                Section(header: Text("재료")) {
                    ForEach(0..<ingredients.count, id: \.self) { index in
                        HStack(spacing: 5) {
                            TextField("재료 \(index + 1)", text: $ingredients[index].name)
                                .frame(width: 100)
                            
                            TextField("", value: $ingredients[index].number, format: .number)
                                .frame(minWidth: 10)
                                .fixedSize()
                            
                            TextField("단위", text: $ingredients[index].scale)
                                .fixedSize()
                            
                            Button(action: {
                                print("pluse")
                                ingredients[index].number += 1
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.blue)
                            }
                            Spacer().frame(width: 2)
                            Button(action: {
                                print("minus")
                                ingredients[index].number -= 1
                            }) {
                                Image(systemName: "minus")
                                    .foregroundColor(.blue)
                            }
//
                            Spacer()
                            
                            Button(action: {
                                ingredients.remove(at: index)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                            .disabled(ingredients.count == 1)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())

                    
                    Button(action: {
                        ingredients.append(Ingredient())
                    }) {
                        Label("재료 추가", systemImage: "plus.circle")
                    }
                    
                    IngredientGridView { ingredient in
                        if ingredients.last?.name == "" {
                            let _ = ingredients.popLast()
                        }
                        ingredients.append(Ingredient(name: ingredient, number: 1, scale: "스푼"))
                    }
                }
                
                Section(header: Text("조리 단계")) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        HStack {
                            TextField("단계 \(index + 1)", text: $steps[index], axis: .vertical)
                                .lineLimit(1...5)
                            
                            Button(action: {
                                steps.remove(at: index)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                            .disabled(steps.count == 1)
                        }
                    }
                    
                    Button(action: {
                        steps.append("")
                    }) {
                        Label("단계 추가", systemImage: "plus.circle")
                    }
                }
                Section(header: Text("공유 설정")) {
                    Toggle("다른 사용자와 공유", isOn: $isShared)
                        .tint(.blue)
                    
                    if isShared {
                        Text("이 레시피는 다른 사용자들과 공유됩니다.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("이 레시피는 내 기기에만 저장됩니다.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("새 레시피")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveRecipe()
                        dismiss()
                    }
                    .disabled(title.isEmpty || steps.contains(""))
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
    
    private func saveRecipe() {
        // 빈 항목 필터링
        let filteredIngredients = ingredients.filter { !$0.name.isEmpty }
        let filteredSteps = steps.filter { !$0.isEmpty }
        
        // 이미지 데이터 변환
        let imageData = selectedImage?.jpegData(compressionQuality: 0.7)
        
        let recipe = Recipe(
            title: title,
            desc: desc,
            link: link,
            ingredients: filteredIngredients,
            steps: filteredSteps,
            imageData: imageData,
            category: category,
            isShared: isShared
        )
        
        modelContext.insert(recipe)
    }
}
