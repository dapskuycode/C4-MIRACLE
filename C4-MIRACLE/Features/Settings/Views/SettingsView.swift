//
//  SettingsView.swift
//  C4-MIRACLE
//
//  Features — Settings / Views
//

import SwiftUI
import FamilyControls

struct SettingsView: View {

    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var screenTime: ScreenTimeService
    @Environment(\.dismiss) private var dismiss

    @State private var showPicker = false
    @State private var resumptionCue = SharedStore.isResumptionCueEnabled

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header

                VStack(spacing: 24) {
                    focusSection
                    notificationsSection
                    accountSection
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .scrollBounceBehavior(.basedOnSize)
        .familyActivityPicker(
            headerText: "Pick Social, Games and Entertainment — or individual apps.",
            isPresented: $showPicker,
            selection: $screenTime.selection
        )
        .onChange(of: showPicker) { _, isShowing in
            guard !isShowing else { return }
            screenTime.persistSelection()
        }
    }

    // MARK: - Header
    
    private var header: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [BrandColors.accent, BrandColors.homeScrim],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )

            characterArtwork
                .scaledToFit()
                .frame(width: 200, height: 200)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .offset(x: 40, y: 26)
                .accessibilityHidden(true)

            HStack(spacing: 14) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(BrandColors.accent)
                        .frame(width: 40, height: 40)
                        .background(.white, in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")
                
                Spacer()
                
                VStack(alignment: .center, spacing: 2) {
                    Text("Settings")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                    Text("costumize your journey")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .frame(maxWidth: 200, alignment: .leading)
            }
            .padding(.horizontal, 20)
            .padding(.top, 56)
        }
        .frame(height: 250)
        .clipShape(WaveShape())
    }

    private var characterArtwork: some View {
        Group {
            if let idle = UIImage(named: "Idle") {
                Image(uiImage: idle).resizable()
            } else {
                Image(.fishing).resizable()
            }
        }
    }

    // MARK: - Focus

    private var focusSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(icon: "nosign", title: "Focus Settings")

            card {
                Button { showPicker = true } label: {
                    row(
                        title: "Blocked Apps",
                        subtitle: "Intercept and block distractions",
                        trailing: Image(systemName: "chevron.right")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                    )
                }
                .buttonStyle(.plain)
                .disabled(!screenTime.isAuthorized)

                if screenTime.hasSelection {
                    Divider().overlay(.white.opacity(1))
                    blockedTiles
                }

                if !screenTime.isAuthorized {
                    Divider().overlay(.white.opacity(1))
                    Text("Screen Time access hasn't been granted, so nothing can be blocked yet.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Divider().overlay(.white.opacity(1))
                }
            }
        }
    }

    private var blockedTiles: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(screenTime.selection.applicationTokens), id: \.self) { token in
                    tile {
                        Label(token)
                            .labelStyle(.iconOnly)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                ForEach(Array(screenTime.selection.categoryTokens), id: \.self) { token in
                    tile {
                        Label(token)
                            .labelStyle(.iconOnly)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
    }

    private func tile<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .frame(width: 40, height: 40)
            .background(.white, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    // MARK: - Notifications

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(icon: "bell.fill", title: "Notifications")

            card {
                Toggle(isOn: $resumptionCue) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Resumption Cue")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                        Text("Remind me to continue working")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
                .tint(.green)
                .onChange(of: resumptionCue) { _, isOn in
                    SharedStore.isResumptionCueEnabled = isOn
                    if isOn {
                        Task { await state.requestNotificationPermission() }
                    }
                }
                Divider().overlay(.white.opacity(1))
            }
        }
    }

    // MARK: - Account & data

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(icon: "sailboat.fill", title: "Account & Data")

            card {
                row(title: "About Miracle", subtitle: "Version \(appVersion)")
                Divider().overlay(.white.opacity(1))
            }
        }
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }

    // MARK: - Building blocks

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
            Text(title)
                .font(.headline)
        }
        .foregroundStyle(BrandColors.accent)
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BrandColors.accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func row(title: String, subtitle: String) -> some View {
        row(title: title, subtitle: subtitle, trailing: EmptyView())
    }

    private func row<Trailing: View>(title: String,
                                     subtitle: String,
                                     trailing: Trailing) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.9))
            }
            Spacer(minLength: 8)
            trailing
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Header shape

/// The rippled bottom edge of the settings header.
///
/// A sine wave rather than hand-placed Bézier curves: `ripples` and `amplitude` then say
/// exactly what the edge looks like, and an integer ripple count guarantees the curve meets
/// both corners at the same height instead of leaving a step.
private struct WaveShape: Shape {

    /// Full crests across the width.
    var ripples: Double = 5
    /// How far a crest rises above the trough, in points.
    var amplitude: CGFloat = 7

    func path(in rect: CGRect) -> Path {
        let baseline = rect.height - amplitude
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.width, y: 0))

        let steps = 120
        for step in stride(from: steps, through: 0, by: -1) {
            let t = Double(step) / Double(steps)
            let y = baseline + sin(t * 2 * .pi * ripples) * amplitude
            path.addLine(to: CGPoint(x: rect.width * t, y: y))
        }

        path.closeSubpath()
        return path
    }
}

// MARK: - Previews

#Preview("Settings") {
    NavigationStack {
        SettingsView()
            .environmentObject(AppState())
            .environmentObject(ScreenTimeService.shared)
    }
}
