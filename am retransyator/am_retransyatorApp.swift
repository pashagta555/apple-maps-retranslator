//
//  am_retransyatorApp.swift
//  am retransyator
//
//  Created by pav on 6/29/25.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var incomingYandexURL: URL?
}

@main
struct am_retransyatorApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState)
                .onOpenURL { url in
                    // Only handle yandexmaps:// links
                    if url.scheme == "yandexmaps" {
                        appState.incomingYandexURL = url
                    }
                }
        }
    }
}
