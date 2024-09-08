




import SwiftUI
import MapKit
import Kingfisher

struct MapView: UIViewRepresentable {
    @StateObject var mapViewModel: MapViewModel
    @Binding var region: MKCoordinateRegion
    
    @Binding var photoDataArray: [PhotoData]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: true)
        // Geohashの範囲を取得してポリゴンを描画
        if let boundingBox = mapViewModel.geohashBoundingBox(for: LocationViewModel.shared.geohash) {
            let coordinates = [
                CLLocationCoordinate2D(latitude: boundingBox.minLat, longitude: boundingBox.minLon), // 左下
                CLLocationCoordinate2D(latitude: boundingBox.maxLat, longitude: boundingBox.minLon), // 左上
                CLLocationCoordinate2D(latitude: boundingBox.maxLat, longitude: boundingBox.maxLon), // 右上
                CLLocationCoordinate2D(latitude: boundingBox.minLat, longitude: boundingBox.maxLon), // 右下
                CLLocationCoordinate2D(latitude: boundingBox.minLat, longitude: boundingBox.minLon)  // 左下に戻る
            ]
            
            // デバッグ用に座標をログに表示
            for coordinate in coordinates {
                print("Coordinate: \(coordinate.latitude), \(coordinate.longitude)")
            }
            
            let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
            mapView.addOverlay(polygon)
            
            // ポリゴンの中央にピンを立てる
            let centerCoordinate = CLLocationCoordinate2D(
                latitude: (boundingBox.minLat + boundingBox.maxLat) / 2,
                longitude: (boundingBox.minLon + boundingBox.maxLon) / 2
            )
            let annotation = MKPointAnnotation()
            annotation.coordinate = centerCoordinate
            annotation.title = "Center of this field."
            mapView.addAnnotation(annotation)
            
            // ポリゴンの範囲に地図をズーム
            let region = MKCoordinateRegion(
                center: centerCoordinate,
                span: MKCoordinateSpan(latitudeDelta: boundingBox.maxLat - boundingBox.minLat,
                                       longitudeDelta: boundingBox.maxLon - boundingBox.minLon)
            )
            mapView.setRegion(mapView.regionThatFits(region), animated: true)
        }
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if let location = LocationViewModel.shared.location {
                    region.center = location.coordinate
                    uiView.setRegion(region, animated: true)
                }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        // ポリゴンの描画を設定
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.strokeColor = UIColor.red
                renderer.lineWidth = 2.0
                renderer.fillColor = UIColor.red.withAlphaComponent(0.1)
                
                // デバッグ用のログ
                print("Rendering polygon with coordinates")
                
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        // ピン（アノテーション）の描画
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "Pin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                // 新しいアノテーションビューを作成
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true  // ピンをタップした時にコールアウト（吹き出し）を表示
                //                        annotationView?.markerTintColor = .blue  // ピンの色を青に設定
            } else {
                // 既存のアノテーションビューを再利用
                annotationView?.annotation = annotation
            }
            
            //                if annotationView == nil {
            //                        annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            //                        annotationView?.canShowCallout = true
            //                        annotationView?.frame = CGRect(x: 0, y: 0, width: 50, height: 50) // ピンのサイズを指定
            //
            //                        // カスタム画像（Kingfisherで画像を読み込む例）
            //                        let imageView = UIImageView(frame: annotationView!.frame)
            //                        imageView.layer.cornerRadius = 25 // 円形にする
            //                        imageView.layer.masksToBounds = true // 角を丸くする
            //
            //                        // Kingfisherで画像を読み込み
            //                        if let customAnnotation = annotation as? CustomAnnotation, let imageUrl = customAnnotation.imageUrl {
            //                            let url = URL(string: imageUrl)
            //                            imageView.kf.setImage(with: url)
            //                        }
            //
            //                        annotationView?.addSubview(imageView)
            //                    } else {
            //                        annotationView?.annotation = annotation
            //                    }
            
            return annotationView
        }
        
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation else { return }
            
            // タップされたピンのタイトルなどを取得
            if let title = annotation.title {
                print("タップされたピンのタイトル: \(title ?? "なし")")
            }
            
            // 必要な処理をここに書く（例えば、シートの表示やデータの取得）
            // 例: シートを表示する
            if let customAnnotation = annotation as? CustomAnnotation {
                // カスタムアノテーションのデータを使って何か処理を実行
                // 例えばシートを表示する
                print("カスタムアノテーションが選択されました: \(customAnnotation.title ?? "")")
                // 必要に応じて、ここでシートのトリガーや他のUI更新を行う
            }
        }
        
    }
}
