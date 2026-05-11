import SwiftUI
import AppKit
import CoreText
import CleaaanCore

@main
struct CleaaanApp: App {

    init() {
        registerFont()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 460, height: 340)

        MenuBarExtra("Cleaaan", systemImage: "sparkles") {
            Button("Mostra Cleaaan") {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.windows.forEach { $0.makeKeyAndOrderFront(nil) }
            }
            Divider()
            Button("Esci") { NSApp.terminate(nil) }
        }
    }

    private func registerFont() {
        // Font is placed at Contents/Resources/Fonts/ by build-app.sh
        guard let url = Bundle.main.url(
            forResource: "Generic-G20-FR-Classic-DEMO",
            withExtension: "otf",
            subdirectory: "Fonts"
        ) else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
}
