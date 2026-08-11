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

    @State private var isConfirmingEnd = false

    var body: some View {
        NavigationStack {
            ZStack {
                if state.isWorkModeActive {
                    workingSession
                } else {
                    idleHome
                }

                if isConfirmingEnd {
                    endConfirmation
                }
            }
            .animation(.easeInOut(duration: 0.25), value: state.isWorkModeActive)
            .animation(.easeInOut(duration: 0.25), value: isConfirmingEnd)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink { SettingsView() } label: {
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

    // MARK: - Idle

    private var idleHome: some View {
        ZStack(alignment: .bottom) {
            backgroundFill
            background
            bottomScrim
            controls
        }
    }

    // MARK: - Working session
    private var workingSession: some View {
        VStack(spacing: 0) {
            workingArtwork
                .scaledToFit()
                .frame(maxHeight: 260)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                Text("Have a great work session!")
                    .font(.title3.bold())
                    .foregroundStyle(BrandColors.ink)

                Text("You can back to work, and we'll see you at your next break")
                    .font(.subheadline)
                    .foregroundStyle(BrandColors.ink)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 32)

                Button { isConfirmingEnd = true } label: {
                    Text("End Work")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(BrandColors.onAccent)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(BrandColors.accent, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.bottom, 8)
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(
                BrandColors.surface,
                in: UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28, style: .continuous)
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .bottom)
    }

    private var workingArtwork: some View {
        Group {
            if let outline = UIImage(named: "FishingOutline") {
                Image(uiImage: outline).resizable()
            } else {
                Image(.fishing).resizable()
            }
        }
    }

    /// Ending a session unblocks everything, so it asks first.
    private var endConfirmation: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { isConfirmingEnd = false }

            VStack(spacing: 10) {
                Image(.fishing)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 78)
                    .accessibilityHidden(true)

                Text("End your work session?")
                    .font(.subheadline.bold())
                    .foregroundStyle(BrandColors.ink)
                    .multilineTextAlignment(.center)

                HStack(spacing: 10) {
                    Button { isConfirmingEnd = false } label: {
                        Text("Cancel")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(BrandColors.ink)
                            .frame(maxWidth: .infinity, minHeight: 40)
                    }
                    .buttonStyle(.plain)

                    Button {
                        isConfirmingEnd = false
                        state.endWorkMode()
                        recap = loadRecap()
                    } label: {
                        Text("End Work")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(BrandColors.onAccent)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(BrandColors.accent, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 2)
            }
            .padding(20)
            .frame(maxWidth: 260)
            .background(BrandColors.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .transition(.scale(scale: 0.92).combined(with: .opacity))
        }
        .accessibilityAddTraits(.isModal)
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
        Image(.homeBg)
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

    /// Only ever starts. Ending happens on the session screen, behind a confirmation.
    private var startButton: some View {
        Button {
            state.startWorkMode()
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
        return "Start Work"
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
