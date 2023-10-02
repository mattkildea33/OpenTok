//
//  ContentView.swift
//  openTok
//
//  Created by Matthew Kildea on 5/15/23.
//
// https://console.firebase.google.com/u/0/project/opentok-a435e/database/opentok-a435e-default-rtdb/data

import Foundation
import SwiftUI
import Firebase
import FirebaseCore

enum Tab {
    case upload
    case player
}

struct ContentView: View {
    var body: some View {
        TabView {
            PlayerView()
                .tabItem {
                    Label("Player", systemImage: "play.circle")
                }
            UploadView()
                .tabItem {
                    Label("Upload", systemImage: "arrow.up.circle")
                }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
