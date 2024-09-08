//
//  MapViewModel.swift
//  HisabisaShader
//
//  Created by 本田輝 on 2024/09/07.
//

import Foundation
import AVFoundation
import Photos
import GeohashKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import CoreLocation

class MapViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    
    static let shared = MapViewModel() 
    
    @Published var photoDatas: [PhotoData] = []
    
    func fetchPhotoDataFromFirestore(completion: @escaping ([PhotoData]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("ユーザーが認証されていません")
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).collection("photos").getDocuments { snapshot, error in
            if let error = error {
                print("Firestoreからのデータ取得中のエラー: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("データが存在しません")
                return
            }
            
            var photoDataArray: [PhotoData] = []
            
            for document in documents {
                do {
                    let photoData = try document.data(as: PhotoData.self)
                    photoDataArray.append(photoData)
                } catch {
                    print("デコード中にエラー: \(error.localizedDescription)")
                }
            }
            
            completion(photoDataArray)
        }
    }
    
    func geohashBoundingBox(for geohash: String) -> (minLat: Double, maxLat: Double, minLon: Double, maxLon: Double)? {
        guard let decodedGeohash = Geohash(geohash: geohash) else {
            return nil
        }
        
        // Geohashの中心座標を取得
        let centerCoordinate = decodedGeohash.coordinates
        
        // Geohashの7桁の範囲の目安 (約152m × 152m)
        let latRange = 0.00152 // 緯度の範囲
        let lonRange = 0.00152 // 経度の範囲
        
        let minLat = centerCoordinate.latitude - latRange / 2
        let maxLat = centerCoordinate.latitude + latRange / 2
        let minLon = centerCoordinate.longitude - lonRange / 2
        let maxLon = centerCoordinate.longitude + lonRange / 2
        
        return (minLat, maxLat, minLon, maxLon)
    }
    
    func fetchPhotoForGeohash(geohash: String) {
        
        Task {
            do {
                photoDatas = try await FirebaseClient.getData(geohash: LocationViewModel.shared.geohash)
            } catch {
                print("ピンデータの取得失敗")
            }
        }
    }
    
}
