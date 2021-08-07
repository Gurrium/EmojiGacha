//
//  EmojiGachaApp.swift
//  EmojiGacha
//
//  Created by gurrium on 2021/08/07.
//

import SwiftUI

@main
struct EmojiGachaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ViewModel())
        }
    }
}
