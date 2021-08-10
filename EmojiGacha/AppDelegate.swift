//
//  AppDelegate.swift
//  EmojiGacha
//
//  Created by gurrium on 2021/08/09.
//

import AppKit
import Carbon
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    let hotKeyId = EventHotKeyID(signature: 1, id: 1)
    var menu: NSMenu?
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let image = NSImage.init(systemSymbolName: "face.smiling", accessibilityDescription: nil) else { return }
        image.isTemplate = true
        statusItem?.button?.image = image

        let menu: NSMenu = {
            let menu = NSMenu()

            let customView = MenuView()
            let hostingView = NSHostingView(rootView: customView)
            hostingView.setFrameSize(.init(width: 320, height: 100))
            let customViewMenuItem = NSMenuItem.init()
            customViewMenuItem.view = hostingView
            menu.addItem(customViewMenuItem)

            let quitMenuItem = NSMenuItem.init(title: "Quit EmojiGacha", action: #selector(quit), keyEquivalent: "q")
            menu.addItem(quitMenuItem)

            return menu
        }()
        statusItem?.menu = menu
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
