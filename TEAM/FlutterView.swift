//
//  FlutterView.swift
//  TEAM
//
//  Created by Mark Adamcin on 7/31/21.
//

import Foundation
import SwiftUI
import Flutter

struct FlutterView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = FlutterViewController
    
    @EnvironmentObject var flutterEngine: FlutterEngineEnvironment
    
    func makeUIViewController(context: Context) -> FlutterViewController {
        let flutterEngine = self.flutterEngine
        let vc = FlutterViewController(engine: flutterEngine.engine!, nibName: nil, bundle: nil)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: FlutterViewController, context: Context) {
        
    }
}
