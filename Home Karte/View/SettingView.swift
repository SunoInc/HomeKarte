//
//  Setting.swift
//  Home Karte
//
//  Created by Shota Sunohara on 2025/02/23.
//

import SwiftUI

struct SettingView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading, spacing: 20) {

                    RoundedRectangle(cornerRadius: 25.0)
                        .fill(
                            LinearGradient(gradient: Gradient(colors: [
                                Color.blue.opacity(0.8),
                                Color.purple.opacity(0.7),
                                Color.purple.opacity(0.7),
                                Color.blue.opacity(0.8),
                            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .shadow(radius: 5)
                        .frame(width: 350, height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25.0)
                                .fill(Color.white.opacity(0.3))
                                .overlay(
                                    HStack {
                                        VStack(alignment: .leading, spacing: 15) {
                                            Text("Welcome to Home Karte")
                                                .font(.system(size: 24, weight: .bold))
                                            Text("Your personal space for your important things.")
                                        }
                                        Spacer()
                                        Image(systemName: "pawprint.fill")
                                            .font(.system(size: 40))
                                            .imageScale(.large)
                                    }
                                    .padding()
                                )
                                .padding()
                                .foregroundColor(.white)
                        )
                    
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text("Settings")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    
                    List {
                        
                        let reviewUrl = URL (string: "https://apps.apple.com/app/id6670766958?ction=write-review")!
                        
                        Link(destination: reviewUrl, label: {
                            HStack {
                                Image(systemName: "star.bubble")
                                VStack(alignment: .leading) {
                                    Text("Rate the app")
                                    Text("Thank you for using this app, I really appriciate it")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        })
                        
                        let shareUrl = URL (string: "https://pps.apple.com/app/id6670766958")
                        
                        //Check the code !
                        ShareLink(item: shareUrl!) {
                            HStack {
                                Image(systemName: "arrowshape.turn.up.left")
                                VStack(alignment: .leading) {
                                    Text("Recommend the app")
                                    Text("To your family, partners and friends")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        //Contact
                        Button {
                            let mailUrl = creatMailUrl()
                            
                            if let mailUrl = mailUrl,
                               UIApplication.shared.canOpenURL(mailUrl) {
                                UIApplication.shared.open(mailUrl)
                            }
                            else {
                                print("Could not open mail")
                            }
                        }
                        label: {
                            HStack {
                                Image(systemName: "quote.bubble")
                                VStack(alignment: .leading) {
                                    Text("Submit Feedback")
                                    Text("I will improve as much as possible")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        //Privacy policy
                        let privacyUrl = URL(string: "https://exmaple.com/abd-privacy-policy/")
                        
                        //Check the code !
                        Link(destination: privacyUrl!, label: {
                            
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Privay Policy")
                            }
                        })
                        
                    }
                    .listRowSeparator(.hidden)
                    .listStyle(.plain)
                    .tint(.black)
                    
                }
                
            }
//                    .navigationTitle("Settings")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                                    dismiss() // 画面を閉じる
                                                }) {
                                                    Text("閉じる")
                                                        .foregroundColor(.blue)
                                                }
                }
            }
        }
    }
    func creatMailUrl() -> URL? {
        var mailUrlComponents = URLComponents()
        mailUrlComponents.scheme = "mailto"
        mailUrlComponents.path = "clifford.s19.pug@gmail.com"
        mailUrlComponents.queryItems = [
            URLQueryItem(name: "Subject", value: "Feed back for Your Buddy App")
        ]
        
        return mailUrlComponents.url
    }
}

#Preview {
    SettingView()
}
