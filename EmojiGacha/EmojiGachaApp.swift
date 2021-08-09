//
//  EmojiGachaApp.swift
//  EmojiGacha
//
//  Created by gurrium on 2021/08/07.
//

import SwiftUI
import AppKit

@main
struct EmojiGachaApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let viewModel = ViewState()

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
                .keyboardShortcut(.space, modifiers: [])
            }
        }
    }
}
