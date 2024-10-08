//
//  ContentView.swift
//  HisabisaShader
//
//  Created by 本田輝 on 2024/09/04.
//

import SwiftUI
import UIKit

struct ContentView: View {
    
    @StateObject private var mapViewModel = MapViewModel()
    @State private var photoDataArray: [PhotoData] = []
    
    var body: some View {
        ZStack {
            WavyGradientBackground()
            AllPhotoView()
        }
    }
}

#Preview {
    ContentView()
}
