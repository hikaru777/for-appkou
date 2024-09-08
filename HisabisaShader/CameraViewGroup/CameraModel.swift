//
//  CameraModel.swift
//  HisabisaShader
//
//  Created by 本田輝 on 2024/09/05.
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

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var session = AVCaptureSession()
    @Published var previewLayer = AVCaptureVideoPreviewLayer()
    
    var output = AVCapturePhotoOutput()
    
    func uploadPhotoToFirebase(imageData: Data, location: CLLocationCoordinate2D, completion: @escaping (Result<String, Error>) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        // ユニークなファイル名（UUID）
        let photoRef = storageRef.child("images/\(UUID().uuidString).jpg")
        
        // 画像データのアップロード
        photoRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("エラー: 写真のアップロード中に問題が発生しました: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            // 画像のダウンロードURLを取得
            photoRef.downloadURL { url, error in
                if let error = error {
                    print("エラー: URLの取得中に問題が発生しました: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                if let downloadURL = url {
                    let hash = Geohash(coordinates: (location.latitude, location.longitude), precision: 7)
                    // PhotoDataモデルを作成
                    let photoData = PhotoData(
                        imageUrl: downloadURL.absoluteString,
                        latitude: location.latitude,
                        longitude: location.longitude,
                        geohash: hash!.geohash.description,
                        timestamp: Timestamp(date: Date())
                    )
                    
                    // Firestoreにデータを保存
                    self.savePhotoDataToFirestore(photoData: photoData)
                    completion(.success(downloadURL.absoluteString))
                }
            }
        }
    }
    
    func savePhotoDataToFirestore(photoData: PhotoData) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("ユーザーが認証されていません")
            return
        }
        
        let db = Firestore.firestore()
        let randomCollectionID = UUID().uuidString
        do {
            let encodedData = try Firestore.Encoder().encode(photoData)
            db.collection("users").document(uid).collection("photos").addDocument(data: encodedData) { error in
                if let error = error {
                    print("Firestoreに保存中のエラー: \(error.localizedDescription)")
                } else {
                    print("写真のデータがFirestoreに保存されました")
                }
            }
        } catch {
            print("データのエンコードエラー: \(error.localizedDescription)")
        }
    }
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupSession()
                    }
                }
            }
        case .denied, .restricted:
            print("カメラのアクセスが拒否されました")
        default:
            break
        }
    }
    
    func setupSession() {
        session.beginConfiguration()
        
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch {
            print("カメラの入力設定に失敗しました: \(error.localizedDescription)")
        }
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        session.commitConfiguration()
        previewLayer.session = session
        session.startRunning()
    }
    
    func takePhoto(completion: @escaping (Data) -> Void) {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
        self.completion = completion
    }
    
    var completion: ((Data) -> Void)?
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("写真のキャプチャ中にエラーが発生しました: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else { return }
        completion?(imageData)
    }
}
