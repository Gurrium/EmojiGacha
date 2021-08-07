//
//  ContentView.swift
//  EmojiGacha
//
//  Created by gurrium on 2021/08/07.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            VStack {
                Text("😀")
                    .font(.system(size: 70))
                Text("grinning_face")
                    .font(.body)
            }
            .padding([.top, .bottom], /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 150))],
                    spacing: 12)
                {
                    ForEach((0...79), id: \.self) { _ in
                        //                let emoji = String(Character(UnicodeScalar(codepoint)!))
                        HStack {
                            Text("\(String(UnicodeScalar(128_512) ?? "a".unicodeScalars.first!))")
                                .font(.title)
                            Text("grinning_face")
                                .font(.caption)
                        }
                        .padding([.leading, .trailing], 4)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
