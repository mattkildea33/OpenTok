//
//  openTokApp.swift
//  openTok
//
//  Created by Matthew Kildea on 5/15/23.
//
import SwiftUI
import Firebase

@main
struct OpenTokApp: App {

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
