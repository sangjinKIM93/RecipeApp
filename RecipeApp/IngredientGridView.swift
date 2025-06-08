//
//  IngredientGridView.swift
//  RecipeApp
//
//  Created by 김상진 on 6/8/25.
//

import SwiftUI

struct IngredientGridView: View {
    var didTapIgredient: ((String) -> Void)?
    
    let rows = [GridItem(.flexible()), GridItem(.flexible())]
    let ingredients: [String] = ["간장", "설탕", "소금", "고추장", "액젓", "식초", "참기름", "다진마늘", "된장", "고추"]
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: rows) {
                ForEach(ingredients, id: \.self) { ingredients in
                    Text(ingredients)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .onTapGesture {
                            didTapIgredient?(ingredients)
                        }
                }
            }
        }
    }
}

#Preview {
    IngredientGridView(didTapIgredient: {_ in })
}
