//
//  TEAMApp.swift
//  TEAM
//
//  Created by Mark Adamcin on 7/31/21.
//

import SwiftUI
import Flutter

@main
struct TEAMApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            FlutterView()
                .ignoresSafeArea(/*@START_MENU_TOKEN@*/.keyboard/*@END_MENU_TOKEN@*/, edges: .bottom)
                .environmentObject(self.appDelegate)
        }
    }
}
