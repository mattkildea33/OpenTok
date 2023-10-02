//
//  UploadView.swift
//  openTok
//
//  Created by Matthew Kildea on 5/15/23.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseCore

struct UploadView: View {
    @State private var url: String = ""
    @State private var description: String = ""
    
    var body: some View {
        VStack {
            Text("Name: ")
                .bold()
                .font(.title)
            
            TextField("Enter Video Name:", text: $description)
                .padding()
            
            Text("Video URL: ")
                .bold()
                .font(.title)
            
            TextField("Enter URL: ", text: $url)
                .padding()
            
            Button("Upload") {
                let ref = Database.database().reference().child("urls").childByAutoId()
                let values = ["name": self.description, "url": self.url]
                ref.setValue(values)
            }
            .font(.headline)
            .padding()
        }
    }
    
    
}
