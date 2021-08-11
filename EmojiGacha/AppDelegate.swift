//
//  AppDelegate.swift
//  EmojiGacha
//
//  Created by gurrium on 2021/08/09.
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        let image = NSImage(systemSymbolName: "face.smiling", accessibilityDescription: "EmojiGacha's status menu")!
        image.isTemplate = true
        statusItem.button?.image = image

        statusItem.menu = {
            let menu = NSMenu()

            let customView = MenuView()
            let hostingView = NSHostingView(rootView: customView)
            hostingView.setFrameSize(.init(width: 320, height: 100))
            let customViewMenuItem = NSMenuItem()
            customViewMenuItem.view = hostingView
            menu.addItem(customViewMenuItem)

            menu.addItem(.separator())

            let quitMenuItem = NSMenuItem(title: "Quit EmojiGacha", action: #selector(quit), keyEquivalent: "q")
            menu.addItem(quitMenuItem)

            return menu
        }()
    }

    @objc private func quit() {
        NSRunningApplication.current.terminate()
    }
}

struct MenuView: View {
    @State var emoji: Emoji = Emoji.random()

    var body: some View {
        VStack {
            Text(emoji.image)
                .font(.system(size: 40))
            Text(emoji.description)
                .font(.system(size: 15))
                .padding([.leading, .trailing])
            Button("gacha") {
                gacha()
            }
        }
    }

    func gacha() {
        emoji = Emoji.random()

        let pboard = NSPasteboard.general
        pboard.clearContents()
        pboard.setString(emoji.image, forType: .string)
    }
}
