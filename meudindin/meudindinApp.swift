//
//  meudindinApp.swift
//  meudindin
//
//  Created by Bento Carlos on 08/12/25.
//

import SwiftUI
import SwiftData

@main
struct meudindinApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity)
                .modelContainer(for: Transaction.self)
        }
        .windowResizability(WindowResizability.contentMinSize)
        .defaultPosition(.center)
    }
}

#Preview {
    ContentView()
}
