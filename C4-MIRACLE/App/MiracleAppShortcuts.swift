//
//  MiracleAppShortcuts.swift
//  C4-MIRACLE
//
//  App
//

import AppIntents

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
