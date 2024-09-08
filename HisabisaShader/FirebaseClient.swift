//
//  FirebaseClient.swift
//  HisabisaShader
//
//  Created by 本田輝 on 2024/09/06.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import SwiftUI

enum FirebaseClientFirestoreError: Error {
    case roomDataNotFound
}

enum FirebaseClient {
    
    static let db = Firestore.firestore()
    
    static func settingProfile(data: AccountData, uid: String) async throws {
        
        guard let encoded = try? Firestore.Encoder().encode(data) else { return }
        try await db.collection("datas").document(uid).setData(encoded)
        
    }
    
    static func getData(geohash: String) async throws -> [PhotoData]{
        var documentDatas = [PhotoData]()
        let db = Firestore.firestore()
        let snapshot = try await db.collection("users").document(Auth.auth().currentUser!.uid).collection(LocationViewModel.shared.geohash).getDocuments()
        let documents = snapshot.documents
        for document in documents {
            do {
                let data = try document.data(as: PhotoData.self)
                documentDatas.append(data)
            } catch {
                print("取得失敗",error.localizedDescription)
            }
        }
        return documentDatas
    }
    
    static func getAllPhotoDatas() async throws -> [PhotoData]{
        var documentDatas = [PhotoData]()
        let db = Firestore.firestore()
        let snapshot = try await db.collection("users").document(Auth.auth().currentUser!.uid).collection("photos").getDocuments()
        let documents = snapshot.documents
        for document in documents {
            do {
                let data = try document.data(as: PhotoData.self)
                documentDatas.append(data)
            } catch {
                print("取得失敗",error.localizedDescription)
            }
        }
        return documentDatas
    }
    
//    static func getPhotoData(geohash: String) async throws -> PhotoData {
//        let db = Firestore.firestore()
//        let snapshot = try await db.collection("users").document(Auth.auth().currentUser!.uid).collection(LocationViewModel.shared.geohash).getDocuments()
//        let documents = snapshot.documents
//        for document in documents {
//            do {
//                let data = try document.data(as: PhotoData.self)
//                documentDatas.append(data)
//            } catch {
//                print("取得失敗",error.localizedDescription)
//            }
//        }
//        return documentDatas
//    }
    
}
