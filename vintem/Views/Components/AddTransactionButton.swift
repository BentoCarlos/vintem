//
//  AddTransactionButton.swift
//  meudindin
//
//  Created by Bento Carlos on 14/02/26.
//

import Foundation
import SwiftUI

struct AddTransactionButton: View {
    let action: () -> Void
    @State var buttonHover: Bool = false

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .padding(10)
        }
        .background(
            Circle()
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                .overlay(
                    Circle()
                        .strokeBorder(.quaternary, lineWidth: 0.5)
                )
        )
        .clipShape(Circle())
        .padding()
        .buttonStyle(.glass)
        .onHover() { isHovering in
            withAnimation(.spring(duration: 0.4)) {
                buttonHover = isHovering
            }
        }
        .scaleEffect(buttonHover ? 1.08 : 1.0)
    }
}
