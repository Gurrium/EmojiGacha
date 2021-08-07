//
//  ContentView.swift
//  EmojiGacha
//
//  Created by gurrium on 2021/08/07.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack {
            VStack {
                let firstEmoji = viewModel.histories.first?.value
                Text(firstEmoji?.image ?? "")
                    .font(.system(size: 70))
                Text(firstEmoji?.description ?? "")
                    .font(.caption)
                Button {
                    viewModel.gacha()
                } label: {
                    Text("gacha")
                }
            }
            .padding([.top, .bottom], 10)
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 150))],
                    alignment: .leading,
                    spacing: 12)
                {
                    ForEach(viewModel.histories, id: \.id) { emoji in
                        HStack {
                            Text(emoji.value.image)
                                .font(.title)
                            Text(emoji.value.description)
                                .font(.caption)
                        }
                        .frame(alignment: .leading)
                        .padding([.leading, .trailing], 4)
                    }
                }
            }
            .padding([.leading, .trailing])
        }
    }
}

class ViewModel: ObservableObject {
    struct IdentifiableEmoji: Identifiable {
        let id: UUID
        let value: Emoji

        init(id: UUID = UUID(), value: Emoji) {
            self.id = id
            self.value = value
        }
    }

    @Published var histories: [IdentifiableEmoji] = []

    init() {
        gacha()
    }

    func gacha() {
        histories.insert(.init(value: Emoji.random()), at: histories.startIndex)
        copyToClipboard()
    }

    func copyToClipboard() {
        guard let emoji = histories.first?.value.image else { return }

        let pboard = NSPasteboard.general
        pboard.clearContents()
        pboard.setString(emoji, forType: .string)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ViewModel())
    }
}
