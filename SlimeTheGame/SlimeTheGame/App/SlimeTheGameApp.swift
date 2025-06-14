//
//  SlimeTheGameApp.swift
//  SlimeTheGame
//
//  Created by MIKHAIL ZHACHKO on 14.06.25.  SlimeTheGameMainView
//

import SwiftUI

@main
struct SlimeTheGameApp: App {
    //MARK: - Properties
    @State var isMenu = false
    @State var isLoad = true
    //MARK: - Views
    var body: some Scene {
        WindowGroup {
            SlimeTheGameView(isPresented: .constant(true))
                .ignoresSafeArea()
        }
        
    }
}
