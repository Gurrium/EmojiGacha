//
//  EmojiGachaApp.swift
//  EmojiGacha
//
//  Created by gurrium on 2021/08/07.
//

import SwiftUI

@main
struct EmojiGachaApp: App {
    let viewModel = ViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
        .commands {
            CommandGroup(after: .textEditing) {
                Button {
                    viewModel.gacha()
                } label: {
                    Text("Gacha")
                }
                .keyboardShortcut(.init(.space, modifiers: []))
            }
        }
    }
}
