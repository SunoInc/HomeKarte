//
//  Home_KarteApp.swift
//  Home Karte
//
//  Created by Shota Sunohara on 2025/02/08.
//

import SwiftUI
import SwiftData

@main
struct Home_KarteApp: App {
    
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Log.self, Medicine.self, MedicalInstitution.self, Appointment.self)
        } catch {
            fatalError("Could not initialize ModelContainer.")
        }
        
        NotificationManager.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
}
