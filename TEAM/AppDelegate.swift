//
//  AppDelegate.swift
//  TEAM
//
//  Created by Mark Adamcin on 7/31/21.
//


import UIKit
import Flutter
// Used to connect plugins (only if you have plugins with iOS platform code).
#if canImport(FlutterPluginRegistrant)
import FlutterPluginRegistrant
#endif
#if canImport(Firebase)
import Firebase
#endif

class AppDelegate: FlutterAppDelegate, ObservableObject { // More on the FlutterAppDelegate.
    
    lazy var flutterEngine = FlutterEngine(name: "team-flutter")
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if canImport(Firebase)
        FirebaseApp.configure()
        #endif
        // Runs the default Dart entrypoint with a default Flutter route.
        flutterEngine.run()
        // Used to connect plugins (only if you have plugins with iOS platform code).
        #if canImport(FlutterPluginRegistrant)
        GeneratedPluginRegistrant.register(with: self.flutterEngine);
        #endif
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions);
    }
}
