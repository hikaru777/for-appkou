//
//  CustomAnnotation.swift
//  HisabisaShader
//
//  Created by 本田輝 on 2024/09/07.
//

import MapKit

// カスタムアノテーション
class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var imageUrl: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?,imageUrl: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
    }
}
