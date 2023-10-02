//
//  PlayerView.swift
//  openTok
//
//  Created by Matthew Kildea on 5/15/23.
//
import Foundation
import SwiftUI
import Firebase
import FirebaseCore
import AVFoundation
import AVKit

// needs sort seen by likes

struct PlayerView: View {
    @State private var player: AVPlayer = AVPlayer()
    @State private var videoURLs: [URL] = []
    @State private var videoNames: [String] = []
    @State private var uniqueIds: [String] = []
    @State private var uvideoURLs: [URL] = []
    @State private var uvideoNames: [String] = []
    @State private var uuniqueIds: [String] = []
    @State private var currentVideoIndex = 0
    @State private var seenVideos: [String] = []
    @State private var firstVid: Bool = false
    @State private var currName: String = ""
    @State private var likedVideos: [String: Int] = [:]
    @State private var currLikedName = ""
    @State private var currLikedURL: URL = URL(string: "ww")!
    @State private var cVidId:String = ""
    @State private var lastSeenIndex:Int = 0
    @State private var cVidLikes:Int = 0
    @State private var prevvideoURLs: [URL] = []
    @State private var prevvideoNames: [String] = []
    @State private var prevuniqueIds: [String] = []
    
    // Fetch video URLs and names from Firebase database
    public func fetchVideoData(completion: @escaping () -> Void) {
        let ref = Database.database().reference(withPath: "urls")
        ref.observeSingleEvent(of: .value) { snapshot in
            var vUrls: [URL] = []
            var vNames: [String] = []
            var ids: [String] = []
            for child in snapshot.children {
                guard let snap = child as? DataSnapshot,
                      let value = snap.value as? [String: Any],
                      let urlString = value["url"] as? String,
                      let url = URL(string: urlString),
                      let name = value["name"] as? String else {
                    continue
                }
                vUrls.append(url)
                vNames.append(name)
                ids.append(snap.key)
            }
            self.videoURLs = vUrls
            self.videoNames = vNames
            self.uniqueIds = ids
            self.uvideoURLs = vUrls
            self.uvideoNames = vNames
            self.uuniqueIds = ids
            moveSeenToEnd()
            print(lastSeenIndex)
            sortSeenByLikes()
            completion()
        }
    }
    
    func moveSeenToEnd() {
        var tempVideoURLs: [URL] = []
        var tempVideoNames: [String] = []
        var tempids: [String] = []
        var ind: Int = 0
        // moves all of the seen videos to the end of list, putting new ones first
        for i in 0..<uniqueIds.count {
            if seenVideos.contains(uniqueIds[i]){
                ind += 1
                let x = videoURLs[i]
                let y = videoNames[i]
                let z = uniqueIds[i]
                tempVideoURLs.append(x)
                tempVideoNames.append(y)
                tempids.append(z)
            }
        }
        lastSeenIndex = videoURLs.count - ind
        for i in 0..<ind {
            videoURLs.removeFirst()
            videoNames.removeFirst()
            uniqueIds.removeFirst()
        }
        for i in tempVideoNames {
            videoNames.append(i)
        }
        for i in tempVideoURLs {
            videoURLs.append(i)
        }
        for i in tempids {
            uniqueIds.append(i)
        }
    }
    
    func getNameFromID (uId: String) -> String {
        var x = 0
        for i in uuniqueIds {
            if i == uId {
                break
            }
            x += 1
        }
        return uvideoNames[x]
    }
    func getURLFromID (uId: String) -> URL {
        var x = 0
        for i in uuniqueIds {
            if i == uId {
                break
            }
            x += 1
        }
        return uvideoURLs[x]
    }
    
    func sortSeenByLikes(){
        if(firstVid){
            var sortedDict = likedVideos.sorted(by: { $0.value > $1.value })
            // make an array with zero likes that have been viewed
            print(videoNames)
            print(uniqueIds)
            print(lastSeenIndex)
            print(videoURLs.count)
            for i in lastSeenIndex..<videoURLs.count {
                uniqueIds.removeLast()
                videoURLs.removeLast()
                videoNames.removeLast()
            }
            for sortId in sortedDict {
                uniqueIds.append(sortId.key)
                videoNames.append(getNameFromID(uId: sortId.key))
                videoURLs.append(getURLFromID(uId: sortId.key))
            }
            for i in uuniqueIds {
                if uniqueIds.contains(i) == false {
                    uniqueIds.append(i)
                }
            }
            for i in uvideoNames {
                if videoNames.contains(i) == false {
                    videoNames.append(i)
                }
            }
            for i in uvideoURLs {
                if videoURLs.contains(i) == false {
                    videoURLs.append(i)
                }
            }
        }
    }
    
    func likeVideo() {
        let currentVideoId = cVidId
        if let likes = likedVideos[currentVideoId] {
            likedVideos[currentVideoId] = 1 + likes
        } else {
            likedVideos[currentVideoId] = 1
        }
        let ref = Database.database().reference(withPath: "likes/mkildea/\(currentVideoId)")
        ref.setValue(likedVideos[currentVideoId])
        fetchLikes(forVideoWithId: cVidId)
    }
    
    func fetchLikes(forVideoWithId videoId: String) {
        let ref = Database.database().reference(withPath: "likes/mkildea/\(videoId)")
        ref.observeSingleEvent(of: .value) { snapshot in
            if let likesCount = snapshot.value as? Int {
                cVidLikes = likesCount
            } else {
                cVidLikes = 0
            }
        }
    }

    func nextVideo() {
        print("Start of nextVideo:")
        print(videoNames)
        if videoURLs.count == 0 {
            fetchVideoData {}
            print("Fetching Video Data...")
        } else {
            if videoURLs.count == 0 {
                fetchVideoData {}
            }
            prevvideoURLs.append(videoURLs[0])
            prevvideoNames.append(videoNames[0])
            prevuniqueIds.append(uniqueIds[0])
            currName = videoNames[0]
            print(currName)
            cVidId = uniqueIds[0]
            let nextVideo = videoURLs[0]
            fetchLikes(forVideoWithId: cVidId)
            player.replaceCurrentItem(with: AVPlayerItem(url: nextVideo))
            print("Before markVideoAsSeen:")
            print(videoNames)
            print(videoURLs)
            print(uniqueIds)
            markVideoAsSeen()
            print("After markVideoAsSeen:")
            print(videoNames)
            print(videoURLs)
            print(uniqueIds)
            firstVid = true
        }
        firstVid = true
    }
    
    func prevVideo() {
        print(prevvideoNames)
        currName = prevvideoNames.popLast()!
        print(currName)
        cVidId = prevuniqueIds.popLast()!
        let nextVideo = prevvideoURLs.popLast()!
        fetchLikes(forVideoWithId: cVidId)
        player.replaceCurrentItem(with: AVPlayerItem(url: nextVideo))
    }
    
    // Mark the current video as seen
    func markVideoAsSeen() {
        seenVideos.append(uniqueIds[currentVideoIndex])
        let ref = Database.database().reference(withPath: "seen/mkildea/\(uniqueIds[currentVideoIndex])")
        ref.setValue(true)
        videoURLs.remove(at: 0)
        videoNames.remove(at: 0)
        uniqueIds.remove(at: 0)
    }
    
    init() {
        player = AVPlayer()
    }

    var body: some View {
        VStack {
            if firstVid {
                Text(currName)
                    .padding(.top, 30)
            } else {
                Text("")
                    .padding(.top, 30)
            }
            VideoPlayer(player: player)
                .padding(.top, 20)
                .padding(.bottom, 20)
            Button(action: {
                likeVideo()
            }) {
                HStack {
                    Image(systemName: "hand.thumbsup.fill")
                        .foregroundColor(.blue)
                    Text("\(cVidLikes)")
                }
            }

            .padding(.bottom, 30)
            HStack {
                Button(action: {
                    prevVideo()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.black)
                    Text("Prev")
                }
                
                Spacer()
                
                Button(action: {
                    nextVideo()
                }) {
                    Text("Next")
                    Image(systemName: "arrow.right")
                        .foregroundColor(.black)
                }
            }
            .padding()
            Button("Update Video List") {
                fetchVideoData {}
            }
            .padding()
        }
        .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width < 0 {
                            nextVideo()
                        } else {
                            prevVideo()
                        }
                    }
            )
    }
}
