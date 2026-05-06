//
//  FireLimeApp.swift
//  FireLime
//
//  Created by Apple on 05/05/2026.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    let options = FirebaseOptions(googleAppID: "1:501143449550:ios:db397020d7a1c074bdc59f",
                                  gcmSenderID: "501143449550")
    options.apiKey = "AIzaSyB19l2btvDoRU5uCUEEB17NqG3kMlZOfvY"
    options.projectID = "firelime-bd687"
    options.clientID = "501143449550-32dgq9hbtsa5acl0v2ps7on20ir7a913.apps.googleusercontent.com"
    FirebaseApp.configure(options: options)
    return true
  }
}

@main
struct FireLimeApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
     
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
