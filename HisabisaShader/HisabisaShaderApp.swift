//
//  HisabisaShaderApp.swift
//  HisabisaShader
//
//  Created by 本田輝 on 2024/09/04.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()

        Auth.auth().addStateDidChangeListener { auth, user in
            if user == nil {
                Auth.auth().signInAnonymously() { (authResult, error) in
                    if error != nil {
                        print("Auth Error :\(error!.localizedDescription)")
                    }
                    Task {
                        do {
                            let profileData = AccountData(name: "", imageUrl: URL(string: ""))
                            try await FirebaseClient.settingProfile(data: profileData, uid: Auth.auth().currentUser!.uid)

                            UserDefaults.standard.set(true, forKey: "logIned")

                        } catch {
                            print("アカウント作成時のエラー",error.localizedDescription)
                        }
                    }

                    // 認証情報の取得
                    guard (authResult?.user) != nil else { return }
                    return
                }
            } else {
                print("ログインできた")
                UserDefaults.standard.set(true, forKey: "logIned")
            }
        }

        return true
    }
}

@main
struct HisabisaShaderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}
