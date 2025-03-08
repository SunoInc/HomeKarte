//
//  ContentView.swift
//  Home Karte
//
//  Created by Shota Sunohara on 2025/02/08.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1

    var body: some View {
        TabView(selection: $selectedTab) {
            TimelineView()
                .tabItem {
                    Label("予定", systemImage: selectedTab == 0 ? "circle.badge.checkmark.fill" : "circle")
                }
                .tag(0)
            
            LogView()
                .tabItem {
                    Label("通院記録", systemImage: selectedTab == 1 ? "app.badge.checkmark.fill" : "app.fill")
                }
                .tag(1)
            
            MedicineView()
                .tabItem {
                    Label("薬", systemImage: selectedTab == 2 ? "pills.fill" : "pill.fill")
                }
                .tag(2)
        }
        .tint(Color.black)
    }
}


#Preview {
    ContentView()
}
