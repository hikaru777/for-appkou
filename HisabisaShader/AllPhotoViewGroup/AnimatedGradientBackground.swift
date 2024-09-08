//
//  AnimatedGradientBackground.swift
//  HisabisaShader
//
//  Created by 本田輝 on 2024/09/09.
//

import SwiftUI

struct WavyGradientBackground: View {
    @State private var animateGradient = false

    var body: some View {
        ZStack {
            // 動的に変化するグラデーション背景
            AngularGradient(
                gradient: Gradient(colors: [.blue, .purple/*, .pink, .orange*/, .indigo]),
                center: animateGradient ? .center : .leading,
                angle: .degrees(animateGradient ? 360 : 0)
            )
            .scaleEffect(1.5) // スケールを大きくして波のような動きを強調
            .blur(radius: 200) // グラデーションをぼかして柔らかい効果
            .animation(Animation.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animateGradient)
            .onAppear {
                animateGradient.toggle() // アニメーションを開始
            }
        }
        .ignoresSafeArea() // 画面全体に表示
    }
}
