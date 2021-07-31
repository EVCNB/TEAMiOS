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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var flutterEngine = FlutterEngineEnvironment()
    
    var body: some Scene {
        WindowGroup {
            FlutterView().environmentObject(flutterEngine)
        }
        .onChange(of: scenePhase) { (newScenePhase) in
            if newScenePhase == .active {
                flutterEngine.engine = appDelegate.flutterEngine
            }
        }
    }
}
