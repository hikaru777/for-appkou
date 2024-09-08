//
//  LocationViewModel.swift
//  HisabisaShader
//
//  Created by 本田輝 on 2024/09/06.
//

import Foundation
import SwiftUI
import CoreLocation
import Firebase
import FirebaseAnalytics
import CoreLocation
import FirebaseCore
import FirebaseFirestore
import MapKit
import GeohashKit

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    static let shared = LocationViewModel()
    
    private var locationManager: CLLocationManager?
    
    @Published var startLocation: CLLocationCoordinate2D?
    @Published var location: CLLocation? = nil
    @Published var geohash: String = "xn76ck6"
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest // 位置情報取得の精度
        locationManager?.distanceFilter = 0.5 // 位置情報取得間隔
        locationManager?.pausesLocationUpdatesAutomatically = false // 自動停止無効
        locationManager?.allowsBackgroundLocationUpdates = true // バックグラウンドでの位置情報更新を許可
        
        checkLocationAuthorizationStatus()
    }
    
    func checkLocationAuthorizationStatus() {
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus { // iOS 14以降で推奨
        case .notDetermined:
            print("許可、不許可を選択していない")
            locationManager.requestWhenInUseAuthorization() // 使用中のみの許可を要求
        case .restricted:
            print("機能制限している")
        case .denied:
            print("許可していない")
        case .authorizedAlways:
            print("常に許可している")
            locationManager.startUpdatingLocation() // 常時許可されている場合は開始
        case .authorizedWhenInUse:
            print("このアプリ使用中のみ許可している")
            locationManager.startUpdatingLocation() // 使用中のみ許可されている場合は開始
        @unknown default:
            return
        }
    }
    
    // CLLocationManagerDelegateのメソッド
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.startLocation = location.coordinate
            self.location = location
            print("現在地: 緯度\(location.coordinate.latitude), 経度\(location.coordinate.longitude)")
            geohash = Geohash(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), precision: 7)!.geohash.description
            
        }
    }
    
    func getNowGeohash(location: CLLocationCoordinate2D) {
        
        geohash = Geohash(location, precision: 7).debugDescription
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 許可状態が変わった際の処理
        checkLocationAuthorizationStatus()
    }
}
