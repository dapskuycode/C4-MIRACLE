//
//  RootView.swift
//  C4-MIRACLE
//
//  App
//

import SwiftUI

struct RootView: View {

    @EnvironmentObject private var state: AppState

    var body: some View {
        Group {
            if state.hasOnboarded {
                HomeView()
            } else {
                OnboardingView()
            }
        }
        // The break screen is presented over whatever is showing, because the request can
        // arrive at any moment — the shield hands us the user without warning.
        .sheet(item: $state.pendingRequest) { request in
            BreakConfigView(request: request)
        }
    }
}
