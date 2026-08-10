//
//  MiracleAppShortcuts.swift
//  C4-MIRACLE
//
//  App
//

import AppIntents

/// App Shortcuts ARE registered automatically. The moment the app is installed these actions
/// appear in the Shortcuts app under "C4-MIRACLE" and become available to Siri, with no user
/// action at all.
///
/// What is NOT automatic is an *automation* — the "When Instagram is Opened" trigger. Actions
/// and automations are different things, and iOS exposes an API for the first and none
/// whatsoever for the second. It is not needed here anyway: the block screen opens the app
/// directly.
struct MiracleAppShortcuts: AppShortcutsProvider {

    static var shortcutTileColor: ShortcutTileColor = .navy

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartWorkModeIntent(),
            phrases: [
                "Start work mode in \(.applicationName)",
                "Begin focusing with \(.applicationName)"
            ],
            shortTitle: "Start Work Mode",
            systemImageName: "bolt.horizontal.circle.fill"
        )
        AppShortcut(
            intent: EndWorkModeIntent(),
            phrases: [
                "End work mode in \(.applicationName)",
                "Stop focusing with \(.applicationName)"
            ],
            shortTitle: "End Work Mode",
            systemImageName: "stop.circle.fill"
        )
        AppShortcut(
            intent: EndBreakIntent(),
            phrases: [
                "End my break in \(.applicationName)"
            ],
            shortTitle: "End Break",
            systemImageName: "hourglass.bottomhalf.filled"
        )
    }
}
