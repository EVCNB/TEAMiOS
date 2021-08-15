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
    
    @EnvironmentObject var appDelegate: AppDelegate
    
    func makeUIViewController(context: Context) -> FlutterViewController {
        let appDelegate = self.appDelegate
        let vc = FlutterViewController(engine: appDelegate.flutterEngine, nibName: nil, bundle: nil)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: FlutterViewController, context: Context) {
        
    }
}
