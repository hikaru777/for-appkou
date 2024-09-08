//
//  AllPhotoView.swift
//  HisabisaShader
//
//  Created by 本田輝 on 2024/09/08.
//

//
//  AllPhotoView.swift
//  HisabisaShader
//
//  Created by 本田輝 on 2024/09/08.
//

import SwiftUI
import Kingfisher
import MapKit

struct AllPhotoView: View {
    @State var photoDatas: [PhotoData] = []
    @State private var selectedGeohashes: Set<String> = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.658581, longitude: 139.745433),  // 東京タワーの座標
        span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)  // 地図のズームレベル
    )
    @State private var showMapView = false
    @State private var showCameraView = false
    // 2列のグリッド構成
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ZStack {
            
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        // geohashを昇順で並べて表示
                        ForEach(geohashes().sorted(), id: \.self) { geohashID in
                            VStack(alignment: .leading) {
                                Text(geohashID)
                                    .font(.headline)
                                    .foregroundStyle(.black)
                                    .padding(.leading)
                                
                                ZStack {
                                    // 同じgeohashの写真を重ねる
                                    let photos = photosForGeohash(geohashID: geohashID)
                                    
                                    // 重なっている写真すべてに処理を適用
                                    ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                                        // すべての写真を微妙に傾ける
                                        
                                        let baseRotation: Angle = (index != 0) && selectedGeohashes.contains(geohashID) ? .degrees(-30) : .degrees(0)
                                        let offsetValue: CGFloat = (index != 0 && selectedGeohashes.contains(geohashID)) ? -50 : 0
                                        
                                        KFImage(URL(string: photo.imageUrl))
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 150, height: 250)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .shadow(radius: 10)
                                            .rotationEffect(baseRotation)
                                            .offset(x: offsetValue)
                                            .animation(.easeInOut(duration: 0.3), value: baseRotation)
                                        //                                        .gesture(longPressGesture(geohashID: geohashID))
//                                            .gesture(
//                                                DragGesture().exclusively(before: LongPressGesture(minimumDuration: 0.3))
//                                                    .onEnded { value in
//                                                        if ExclusiveGesture<DragGesture, LongPressGesture>.Value.second != nil {
//                                                            withAnimation {
//                                                                if selectedGeohashes.contains(geohashID) {
//                                                                    selectedGeohashes.remove(geohashID)
//                                                                } else {
//                                                                    selectedGeohashes.insert(geohashID)
//                                                                }
//                                                            }
//                                                        }
//                                                    }
//                                            )
                                            .onTapGesture(count: 2) {
                                                withAnimation {
                                                    if selectedGeohashes.contains(geohashID) {
                                                        selectedGeohashes.remove(geohashID)
                                                    } else {
                                                        selectedGeohashes.insert(geohashID)
                                                    }
                                                }
                                            }
                                    }
                                    .foregroundStyle(.clear)
                                }
                                .foregroundStyle(.clear)
                                .frame(height: 250)
                            }
                            .foregroundStyle(.clear)
                        }
                        .foregroundStyle(.clear)
                    }
//                    .background(WavyGradientBackground())
                    .foregroundStyle(.clear)
                    .padding(.top, 20)
                    .padding(.horizontal)
                }
                .background(WavyGradientBackground())
                .foregroundStyle(.clear)
                .onAppear {
                    Task {
                        do {
                            photoDatas = try await FirebaseClient.getAllPhotoDatas()
                        } catch {
                            print("photoDatasとってこれてない")
                        }
                    }
                }
                .onChange(of: LocationViewModel.shared.location, perform: {_ in
                    region = MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: LocationViewModel.shared.location!.coordinate.latitude, longitude: LocationViewModel.shared.location!.coordinate.longitude),  // 東京タワーの座標
                        span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)  // 地図のズームレベル
                    )
                })
                .toolbarBackground(.ultraThinMaterial.opacity(0.1), for: .automatic)
                .toolbar {
                    //場所の指定をせずにアイテムを配置
                    //                ToolbarItem() {//placement: .navigationBarLeading) {
                    //                    Text("テキスト")
                    //                }
                    //アイテムをキャンセルアクションの位置に配置
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            withAnimation {
                                showMapView.toggle()
                            }
                        } label: {
                            Image(systemName: "mappin.and.ellipse.circle.fill")
                                .resizable()
                                .foregroundColor(.black)
                                .frame(width: 35, height: 35)
                        }
                        .padding(5)
                        
                    }
                    //アイテムを確認アクションの位置に配置
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            withAnimation {
                                showCameraView.toggle()
                            }
                        } label: {
                            Image(systemName: "camera.circle.fill")
                                .resizable()
                                .foregroundColor(.black)
                                .frame(width: 35, height: 35)
                        }
                        .padding(5)
                    }
                    //                //複数のツールバーのアイテムをグループとする
                    //                //画面した部分に配置する
                    //                ToolbarItemGroup(placement: .bottomBar) {
                    //                    Button(action: {}) {
                    //                        Image(systemName: "doc.badge.plus")
                    //                            .resizable()
                    //                            .scaledToFit()
                    //                            .frame(width: 50, height: 50)
                    //                    }
                    //                    Button(action: {}) {
                    //                        Image(systemName: "calendar")
                    //                            .resizable()
                    //                            .scaledToFit()
                    //                            .frame(width: 50, height: 50)
                    //                    }
                    //                }
                }
            }.foregroundStyle(.clear)
            
            if showMapView {
                Rectangle()
                    .foregroundStyle(.ultraThinMaterial.opacity(0.5))
                    .frame(maxWidth: .infinity,maxHeight: .infinity)
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showMapView.toggle()
                        }
                    }
            }
            MapView(mapViewModel: .init(), region: $region, photoDataArray: $photoDatas)
                .frame(width: 300,height: 500)
                .cornerRadius(20)
                .offset(y: showMapView ? 0 : UIScreen.main.bounds.height)
            
        }
        .edgesIgnoringSafeArea(.bottom)
        .fullScreenCover(isPresented: $showCameraView) {
            CameraView(camera: .init(), locationViewModel: .init())
        }
    }
    
    // ユニークなgeohashのリストを取得して昇順にソート
    func geohashes() -> [String] {
        let uniqueGeohashes = Set(photoDatas.map { $0.geohash })
        return Array(uniqueGeohashes).sorted() // 昇順にソート
    }
    
    // geohashIDで写真をフィルタリングする
    func photosForGeohash(geohashID: String) -> [PhotoData] {
        return photoDatas.filter { $0.geohash == geohashID }
    }
    
    // LongPressGesture を個別に定義
    func longPressGesture(geohashID: String) -> some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .onChanged { _ in
                // 長押し中に geohash を追加
                selectedGeohashes.insert(geohashID)
            }
            .onEnded { _ in
                // 少し遅らせて削除処理を行う
                DispatchQueue.main.async {
                    selectedGeohashes.remove(geohashID)
                }
            }
    }
}


struct PhotoDetailView: View {
    let photo: PhotoData
    
    var body: some View {
        VStack {
            KFImage(URL(string: photo.imageUrl))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Text("地域: \(photo.geohash)")
                .font(.headline)
                .padding()
        }
        .navigationTitle("写真の詳細")
    }
}

