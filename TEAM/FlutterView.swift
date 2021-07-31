//
//  FlutterViewControllerRepresentable.swift
//  TEAM
//
//  Created by Mark Adamcin on 7/31/21.
//

import Foundation
import SwiftUI
import Flutter

struct FlutterView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = FlutterViewController
    
    func makeUIViewController(context: Context) -> FlutterViewController {
        let vc = FlutterViewController()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: FlutterViewController, context: Context) {
        
    }
}
