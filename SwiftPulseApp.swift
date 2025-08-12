//
//  SwiftPulseApp.swift
//  SwiftPulse
//
//  Created by ExtMac on 8/10/25.
//

import SwiftUI
import SwiftData

@main
struct SwiftPulseApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(persistenceController.modelContainer)
    }
}
