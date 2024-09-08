//
//  AllPhotoView.swift
//  HisabisaShader
//
//  Created by 本田輝 on 2024/09/08.
//

import SwiftUI
import Kingfisher

struct AllPhotoView: View {
    @State var photoDatas: [PhotoData] = []
    @State private var selectedGeohashes: Set<String> = [] // 選択されたgeohashのリスト
    
    // 2列のグリッド構成
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    // geohashを昇順で並べて表示
                    ForEach(geohashes().sorted(), id: \.self) { geohashID in
                        VStack(alignment: .leading) {
                            Text("Geohash: \(geohashID)")
                                .font(.headline)
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
                                        .shadow(radius: 5)
                                        .rotationEffect(baseRotation)
                                        .offset(x: offsetValue)
                                        .animation(.easeInOut(duration: 0.3), value: baseRotation)
                                    //                                        .gesture(longPressGesture(geohashID: geohashID))
                                        .gesture(
                                            DragGesture().exclusively(before: LongPressGesture(minimumDuration: 0.5))
                                                .onEnded { value in
                                                    if ExclusiveGesture<DragGesture, LongPressGesture>.Value.second != nil {
                                                        withAnimation {
                                                            if selectedGeohashes.contains(geohashID) {
                                                                selectedGeohashes.remove(geohashID)
                                                            } else {
                                                                selectedGeohashes.insert(geohashID)
                                                            }
                                                        }
                                                    }
                                                }
                                        )
                                }
                            }
                            .frame(height: 250)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("地域別の写真一覧")
            .onAppear {
                Task {
                    do {
                        photoDatas = try await FirebaseClient.getAllPhotoDatas()
                    } catch {
                        print("photoDatasとってこれてない")
                    }
                }
            }
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

