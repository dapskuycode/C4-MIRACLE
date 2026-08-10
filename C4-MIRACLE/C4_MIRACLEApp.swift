//
//  C4_MIRACLEApp.swift
//  C4-MIRACLE
//
//  Created by M Daffa Atstsaqif on 02/08/26.
//

import SwiftUI

@main
struct C4_MIRACLEApp: App {

    @StateObject private var state = AppState()
    @StateObject private var screenTime = ScreenTimeService.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(state)
                .environmentObject(screenTime)
                .onOpenURL { state.handle(url: $0) }
                .onChange(of: scenePhase) { _, phase in
                    guard phase == .active else { return }
                    screenTime.refreshAuthorizationStatus()
                    state.refresh()
                }
        }
    }
}
