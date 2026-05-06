//
//  ContentView.swift
//  FireLime
//
//  Created by Apple on 05/05/2026.
//

import SwiftUI
import FirebaseCore

struct ContentView: View {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        Group {
            if authManager.user != nil {
                HomeView()
            } else {
                LoginView()
            }
        }
        .animation(.default, value: authManager.user) 
    }
}

#Preview {
    if FirebaseApp.app() == nil {
        // Manually configure for the preview so it doesn't crash if the plist is missing from the bundle
        let options = FirebaseOptions(googleAppID: "1:501143449550:ios:db397020d7a1c074bdc59f",
                                      gcmSenderID: "501143449550")
        options.apiKey = "AIzaSyB19l2btvDoRU5uCUEEB17NqG3kMlZOfvY"
        options.projectID = "firelime-bd687"
        options.clientID = "501143449550-32dgq9hbtsa5acl0v2ps7on20ir7a913.apps.googleusercontent.com"
        FirebaseApp.configure(options: options)
    }
    return ContentView()
}

