//
//  ContentView.swift
//  TEAM
//
//  Created by Mark Adamcin on 7/31/21.
//

import SwiftUI

struct ContentView: View {
    @State var isShowingFlutterView = false
    var body: some View {
        Button(action: {
                    self.isShowingFlutterView.toggle()
        }) {
                    Text("Tap Me")
        }
        .sheet(isPresented: $isShowingFlutterView) {
            FlutterView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
