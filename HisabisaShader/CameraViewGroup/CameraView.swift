




import SwiftUI
import AVFoundation
import CoreLocation
import MapKit

struct CameraView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.658581, longitude: 139.745433),  // 東京タワーの座標
        span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)  // 地図のズームレベル
    )
    @StateObject var camera: CameraModel
    @ObservedObject var locationViewModel = LocationViewModel()
    @State private var locationManager = CLLocationManager()
    @State private var currentLocation: CLLocationCoordinate2D? = nil
    @State private var photoDataArray: [PhotoData] = []
    
    var body: some View {
        ZStack {
            // カメラプレビュー
            CameraPreview(camera: camera)
                .ignoresSafeArea(.all)
                .onAppear {
                    MapViewModel.shared.fetchPhotoDataFromFirestore { fetchedData in
                        self.photoDataArray = fetchedData
                    }
                }
            
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .resizable()
                            .renderingMode(.original)
                            .foregroundStyle(.black, .white)
                            .frame(width: 35, height: 35)
                    }
                    .padding(5)
                    .padding(.leading, 10)
                    Spacer()
                }
                Spacer()
                
                // 撮影ボタン
                Button(action: {
                    camera.takePhoto { imageData in
                        if let location = locationManager.location?.coordinate {
                            self.currentLocation = location
                            handlePhotoUpload(imageData: imageData, location: location)
                        }
                    }
                }) {
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 5)
                        .frame(width: 80, height: 80)
                        .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            locationViewModel.checkLocationAuthorizationStatus()
            camera.checkCameraPermission()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    // 写真のアップロードとFirestoreへの保存
    private func handlePhotoUpload(imageData: Data, location: CLLocationCoordinate2D) {
        camera.uploadPhotoToFirebase(imageData: imageData, location: location) { result in
            switch result {
            case .success(let downloadURL):
                print("写真がアップロードされました。URL: \(downloadURL)")
                MapViewModel.shared.fetchPhotoDataFromFirestore { fetchedData in
                    self.photoDataArray = fetchedData
                }
            case .failure(let error):
                print("エラーが発生しました: \(error.localizedDescription)")
            }
        }
    }
}


struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        camera.previewLayer.videoGravity = .resizeAspectFill
        camera.previewLayer.frame = view.frame
        view.layer.addSublayer(camera.previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}


