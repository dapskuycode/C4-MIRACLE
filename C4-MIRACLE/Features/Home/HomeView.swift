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
            .toolbar(.hidden, for: .navigationBar) // Hide navigation bar for true full bleed
            .onAppear { recap = loadRecap() }
        }
    }

    // MARK: - Idle

    private var idleHome: some View {
        ZStack {
            // Base fill
            Color(red: 27/255, green: 107/255, blue: 107/255)
                .ignoresSafeArea()
            
            // Full bleed background Harbor
            Image("MainFlow_Homepage_Harbor")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .accessibilityHidden(true)
            
            // Fade scrim color 1B6B6B at the bottom
            LinearGradient(
                colors: [
                    Color(red: 27/255, green: 107/255, blue: 107/255).opacity(0),
                    Color(red: 27/255, green: 107/255, blue: 107/255).opacity(0.65),
                    Color(red: 27/255, green: 107/255, blue: 107/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 380)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            
            // Layout content on top
            VStack(spacing: 0) {
                // Top Custom Header with Settings Gear
                HStack {
                    Spacer()
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .fill(.black.opacity(0.35))
                                    .overlay(
                                        Circle()
                                            .stroke(.white.opacity(0.2), lineWidth: 1.5)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Settings")
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                // Bottom Stack controls
                VStack(spacing: 14) {
                    startButton
                    recapCard
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 36)
            }
        }
    }

    // MARK: - Working session
    private var workingSession: some View {
        VStack(spacing: 0) {
            // Top half: Illustrative scene
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    // 1. Sky background
                    Image("MainFlow_Langit")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                    
                    // 2. Base Sea
                    Image("MainFlow_LautBase")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: 180, alignment: .top)
                        .clipped()
                    
                    // 3. Island (positioned at the far right corner on the horizon)
                    Image("MainFlow_Pulau")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 95)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .offset(x: 25, y: -130)
                    
                    // 4. Fisherman (Mancing Biasa - centered, boat floating clearly above water)
                    fishermanArtwork
                        .resizable()
                        .scaledToFit()
                        .frame(width: 280)
                        .offset(x: 0, y: -45)
                    
                    // 5. Front Sea (shorter wave layer lapping only at bottom edge of hull)
                    Image("MainFlow_LautFront")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: 65, alignment: .top)
                        .clipped()
                    
                    // 6. Transition gradient to blend sea bottom into the top of the card
                    LinearGradient(
                        colors: [
                            Color(red: 235/255, green: 245/255, blue: 246/255).opacity(0),
                            Color(red: 235/255, green: 245/255, blue: 246/255)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: geo.size.width, height: 40)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .top)
            
            // Bottom half: White Overlay Card with top gradient (raised section & button higher up)
            VStack(alignment: .leading, spacing: 22) {
                Text("Do your task!!!! <3")
                    .font(.title2.bold())
                    .foregroundStyle(.black)
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Stay focused on your task. If your attention drifts, we'll help you find your way back.")
                        .font(.body)
                        .foregroundStyle(.black.opacity(0.65))
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Close this app, n enjoy ur work!")
                        .font(.body)
                        .foregroundStyle(.black.opacity(0.65))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, 16)
                
                Button {
                    isConfirmingEnd = true
                } label: {
                    Text("End Work")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(Color(red: 29/255, green: 100/255, blue: 104/255), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.bottom, 52) // Raised button higher up
            }
            .padding(.horizontal, 32)
            .padding(.top, 36)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 235/255, green: 245/255, blue: 246/255),
                        .white
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                in: RoundedRectangle(cornerRadius: 40, style: .continuous)
            )
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .bottom)
    }

    private var fishermanArtwork: Image {
        if UIImage(named: "MancingBiasa") != nil {
            return Image("MancingBiasa")
        } else {
            return Image("NarekPanceng")
        }
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
    
    private struct TopCircleShape: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()

            let curveHeight: CGFloat = 50

            path.move(to: CGPoint(x: rect.minX, y: rect.minY + curveHeight))

            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.minY + curveHeight),
                control: CGPoint(
                    x: rect.midX,
                    y: rect.minY - curveHeight
                )
            )

            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()

            return path
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
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(
                    Color(red: 29/255, green: 100/255, blue: 104/255)
                        .opacity(screenTime.isAuthorized ? 1.0 : 0.5),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
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
        NavigationLink {
            AchievementView()
        } label: {
            HStack(spacing: 20) {
                // Left: Active Master Angler Badge — larger
                Image("SettingSummary_Badge_Active_MasterAngler")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)

                // Center: Stats
                VStack(alignment: .leading, spacing: 6) {
                    Text("Today's Recap")
                        .font(.headline)
                        .foregroundStyle(BrandColors.ink)

                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Text("\(recap.committed)")
                                .font(.title3.bold())
                                .foregroundStyle(Color(red: 29/255, green: 100/255, blue: 104/255))
                            Text("Commit")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }

                        HStack(spacing: 4) {
                            Text("\(recap.missedReturns)")
                                .font(.title3.bold())
                                .foregroundStyle(Color(red: 216/255, green: 125/255, blue: 51/255))
                            Text("Dismiss")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                    }

                    Text("See full summary")
                        .font(.caption2)
                        .foregroundStyle(.gray.opacity(0.8))
                }

                Spacer()

                // Right: Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.gray.opacity(0.5))
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 22)
            .background(
                Color(red: 230/255, green: 242/255, blue: 243/255).opacity(0.92),
                in: RoundedRectangle(cornerRadius: 24, style: .continuous)
            )
        }
        .buttonStyle(.plain)
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
