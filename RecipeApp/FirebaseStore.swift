//
//  FirebaseStore.swift
//  RecipeApp
//
//  Created by 김상진 on 6/28/25.
//

import Foundation
import FirebaseFirestore

// MARK: - Firestore Manager
class FirestoreManager: ObservableObject {
    private let db = Firestore.firestore()
    private let collection = "recipes" // 컬렉션 이름
    
    // MARK: - 데이터 저장
    
    /// 새 레시피 추가
    func addRecipe(_ recipe: Recipe) async throws -> String {
        do {
            let docRef = try await db.collection(collection).addDocument(data: recipe.toFirebase())
            return docRef.documentID
        } catch {
            throw FirestoreError.addFailed(error.localizedDescription)
        }
    }
    
    /// 특정 ID로 레시피 저장/업데이트
    func saveRecipe(_ recipe: Recipe, id: String) async throws {
        do {
            try await db.collection(collection).document(id).setData(recipe.toFirebase())
        } catch {
            throw FirestoreError.saveFailed(error.localizedDescription)
        }
    }
    
    /// 레시피 업데이트 (부분 업데이트)
    func updateRecipe(id: String, fields: [String: Any]) async throws {
        do {
            try await db.collection(collection).document(id).updateData(fields)
        } catch {
            throw FirestoreError.updateFailed(error.localizedDescription)
        }
    }
    
    // MARK: - 데이터 가져오기
    
    /// 모든 레시피 가져오기
    func getAllRecipes() async throws -> [Recipe] {
        do {
            let snapshot = try await db.collection(collection)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            return try snapshot.documents.compactMap { document in
                var recipe = try document.data(as: Recipe.self)
                recipe.remoteId = document.documentID
                return recipe
            }
        } catch {
            throw FirestoreError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// 특정 ID로 레시피 가져오기
    func getRecipe(id: String) async throws -> Recipe? {
        do {
            let document = try await db.collection(collection).document(id).getDocument()
            
            if document.exists {
                var recipe = try document.data(as: Recipe.self)
                recipe.remoteId = document.documentID
                return recipe
            }
            return nil
        } catch {
            throw FirestoreError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// 카테고리별 레시피 가져오기
    func getRecipesByCategory(_ category: String) async throws -> [Recipe] {
        do {
            let snapshot = try await db.collection(collection)
                .whereField("category", isEqualTo: category)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            return try snapshot.documents.compactMap { document in
                var recipe = try document.data(as: Recipe.self)
                recipe.remoteId = document.documentID
                return recipe
            }
        } catch {
            throw FirestoreError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// 즐겨찾기 레시피 가져오기
    func getFavoriteRecipes() async throws -> [Recipe] {
        do {
            let snapshot = try await db.collection(collection)
                .whereField("isFavorite", isEqualTo: true)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            return try snapshot.documents.compactMap { document in
                var recipe = try document.data(as: Recipe.self)
                recipe.remoteId = document.documentID
                return recipe
            }
        } catch {
            throw FirestoreError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// 제목으로 레시피 검색
    func searchRecipes(by title: String) async throws -> [Recipe] {
        do {
            let snapshot = try await db.collection(collection)
                .whereField("title", isGreaterThanOrEqualTo: title)
                .whereField("title", isLessThan: title + "\u{f8ff}")
                .getDocuments()
            
            return try snapshot.documents.compactMap { document in
                var recipe = try document.data(as: Recipe.self)
                recipe.remoteId = document.documentID
                return recipe
            }
        } catch {
            throw FirestoreError.fetchFailed(error.localizedDescription)
        }
    }
    
    // MARK: - 데이터 삭제
    
    /// 레시피 삭제
    func deleteRecipe(id: String) async throws {
        do {
            try await db.collection(collection).document(id).delete()
        } catch {
            throw FirestoreError.deleteFailed(error.localizedDescription)
        }
    }
    
    // MARK: - 실시간 리스너
    
    /// 실시간으로 모든 레시피 감시
    func listenToRecipes(completion: @escaping ([Recipe]) -> Void) -> ListenerRegistration {
        return db.collection(collection)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let recipes = documents.compactMap { document -> Recipe? in
                    do {
                        var recipe = try document.data(as: Recipe.self)
                        recipe.remoteId = document.documentID
                        return recipe
                    } catch {
                        print("Error decoding recipe: \(error)")
                        return nil
                    }
                }
                
                completion(recipes)
            }
    }
    
    /// 특정 카테고리 실시간 감시
    func listenToCategory(_ category: String, completion: @escaping ([Recipe]) -> Void) -> ListenerRegistration {
        return db.collection(collection)
            .whereField("category", isEqualTo: category)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let recipes = documents.compactMap { document -> Recipe? in
                    do {
                        var recipe = try document.data(as: Recipe.self)
                        recipe.remoteId = document.documentID
                        return recipe
                    } catch {
                        print("Error decoding recipe: \(error)")
                        return nil
                    }
                }
                
                completion(recipes)
            }
    }
}

// MARK: - 에러 타입 정의
enum FirestoreError: LocalizedError {
    case addFailed(String)
    case saveFailed(String)
    case updateFailed(String)
    case fetchFailed(String)
    case deleteFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .addFailed(let message):
            return "레시피 추가 실패: \(message)"
        case .saveFailed(let message):
            return "레시피 저장 실패: \(message)"
        case .updateFailed(let message):
            return "레시피 업데이트 실패: \(message)"
        case .fetchFailed(let message):
            return "레시피 불러오기 실패: \(message)"
        case .deleteFailed(let message):
            return "레시피 삭제 실패: \(message)"
        }
    }
}
