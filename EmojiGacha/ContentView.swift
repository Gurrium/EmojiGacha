//
//  ContentView.swift
//  EmojiGacha
//
//  Created by gurrium on 2021/08/07.
//

import SwiftUI
import AppKit

struct ContentView: View {
    static let minWidth: CGFloat = 320
    @ObservedObject var viewModel: ViewState

    var body: some View {
        VStack {
            if let firstEmoji = viewModel.histories.first?.value {
                VStack {
                    Text(firstEmoji.image)
                        .font(.system(size: 70))
                    Text(firstEmoji.description)
                        .font(.system(size: 15))
                    Button("gacha") {
                        viewModel.gacha()
                    }
                }
                .padding([.top, .bottom], 10)
            }
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: Self.minWidth))],
                    alignment: .leading,
                    spacing: 12)
                {
                    ForEach(viewModel.histories, id: \.id) { emoji in
                        HStack {
                            Text(emoji.value.image)
                                .font(.system(size: 40))
                            Text(emoji.value.description)
                                .font(.system(size: 15))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.copyEmojiToClipboard(emoji.value)
                        }
                        .frame(alignment: .leading)
                        .padding([.leading, .trailing], 4)
                    }
                }
            }
            .padding([.leading, .trailing])
            if let emoji = viewModel.mostRecentlyCopiedEmoji?.image {
                Text("\(emoji) is copied")
                    .foregroundColor(.gray)
                    .font(.system(size: 15))
                    .padding(.bottom, 4)
            }
        }
        .frame(minWidth: Self.minWidth)
    }
}

class ViewState: ObservableObject {
    struct IdentifiableEmoji: Identifiable {
        let id: UUID
        let value: Emoji

        init(id: UUID = UUID(), value: Emoji) {
            self.id = id
            self.value = value
        }
    }

    @Published var histories: [IdentifiableEmoji] = []
    @Published var mostRecentlyCopiedEmoji: Emoji?

    init() {
        gacha()
    }

    func gacha() {
        let result = Emoji.random()
        histories.insert(.init(value: result), at: histories.startIndex)
        copyEmojiToClipboard(result)
    }

    func copyEmojiToClipboard(_ emoji: Emoji) {
        let pboard = NSPasteboard.general
        pboard.clearContents()
        if pboard.setString(emoji.image, forType: .string) {
            mostRecentlyCopiedEmoji = emoji
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ViewState())
    }
}
