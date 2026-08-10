//
//  HomeView.swift
//  C4-MIRACLE
//
//  Features — Home
//

import SwiftUI

struct HomeView: View {

    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var screenTime: ScreenTimeService

    @State private var recap = DailyRecap.empty

    private let loadRecap: () -> DailyRecap

    init(recap: @escaping () -> DailyRecap = { .today() }) {
        self.loadRecap = recap
    }

    private var onBreak: Bool {
        guard let grant = state.activeGrant else { return false }
        return grant.isActive
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                backgroundFill
                background
                bottomScrim
                controls
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink { WorkModeView() } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(BrandColors.ink)
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear { recap = loadRecap() }
        }
    }

    // MARK: - Background

    private var backgroundFill: some View {
        LinearGradient(
            colors: [BrandColors.homeWater, BrandColors.homeScrim],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private var background: some View {
        Image(.homeTest1)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .offset(y: -60)
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }

    private var bottomScrim: some View {
        LinearGradient(
            colors: [BrandColors.homeScrim.opacity(0), BrandColors.homeScrim.opacity(0.85), BrandColors.homeScrim],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 300)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    // MARK: - Bottom stack

    private var controls: some View {
        VStack(spacing: 16) {
            startButton
            recapCard
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }

    private var startButton: some View {
        Button {
            state.isWorkModeActive ? state.endWorkMode() : state.startWorkMode()
            recap = loadRecap()
        } label: {
            Text(startButtonTitle)
                .font(.body.weight(.semibold))
                .foregroundStyle(screenTime.isAuthorized ? BrandColors.ink : BrandColors.muted)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(.white, in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!screenTime.isAuthorized)
    }

    private var startButtonTitle: String {
        guard screenTime.isAuthorized else { return "Grant Screen Time access" }
        if onBreak { return "On a break" }
        return state.isWorkModeActive ? "End Work" : "Start Work"
    }

    // MARK: - Today's recap

    private var recapCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's recap")
                .font(.headline)
                .foregroundStyle(.white)

            HStack(alignment: .top, spacing: 12) {
                recapTile(
                    caption: "Look what you did today!",
                    icon: "fish.fill",
                    count: recap.committed,
                )
                recapTile(
                    caption: "See how you did",
                    icon: "trash.fill",
                    count: recap.missedReturns,
                )
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func recapTile(caption: String, icon: String, count: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(caption)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(2, reservesSpace: true)

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(BrandColors.ink)

                VStack(alignment: .leading, spacing: 1) {
                    Text("\(count)X")
                        .font(.title3.bold())
                        .foregroundStyle(BrandColors.ink)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(.white.opacity(0.85),
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Previews

private extension View {
    func homePreviewEnvironment() -> some View {
        environmentObject(AppState())
            .environmentObject(ScreenTimeService.shared)
    }
}

#Preview("Home") {
    HomeView(recap: { DailyRecap(committed: 3, missedReturns: 0) })
        .homePreviewEnvironment()
}
