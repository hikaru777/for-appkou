//
//  Models.swift
//  spring-canp2024
//
//  Created by 本田輝 on 2024/03/26.
//

import Foundation
import FirebaseFirestore
import CoreLocation

// PhotoDataモデル
struct PhotoData: Codable, Identifiable, Equatable, Hashable{
    @DocumentID var id: String?
    var imageUrl: String
    var latitude: Double
    var longitude: Double
    var geohash: String
    var timestamp: Timestamp
}
    
struct Message: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    let sender: String?
    let body: String?
    let time: Timestamp?
    
    var encoded: [String: Any] {
        get throws {
            try Firestore.Encoder().encode(self)
        }
    }
}

struct AccountData: Codable {
    @DocumentID var uid: String?
    var name: String
    var imageUrl: URL?
    var encoded: [String: Any] {
        get throws {
            try Firestore.Encoder().encode(self)
        }
    }
}
