//
//  OnboardingView.swift
//  C4-MIRACLE
//
//  Features — ScreenTime / Views
//

import SwiftUI
import FamilyControls

// MARK: - Main Onboarding Container (8 Steps)

struct OnboardingView: View {

    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var screenTime: ScreenTimeService
    @State private var currentStep: Int = 1
    @State private var showPicker: Bool = false

    var body: some View {
        ZStack {
            switch currentStep {
            case 1:
                OnboardingStep1View(onNext: { currentStep = 2 })
            case 2:
                OnboardingStep2View(onNext: { currentStep = 3 })
            case 3:
                OnboardingStep3View(onNext: { currentStep = 4 })
            case 4:
                OnboardingStep4View(onNext: { currentStep = 5 })
            case 5:
                OnboardingStep5View(
                    onConfirm: {
                        Task {
                            await state.requestNotificationPermission()
                            await screenTime.requestAuthorization()
                            currentStep = 6
                        }
                    },
                    onNext: {
                        Task {
                            await state.requestNotificationPermission()
                            await screenTime.requestAuthorization()
                            currentStep = 6
                        }
                    }
                )
            case 6:
                OnboardingStep6View(
                    onAddApp: {
                        Task {
                            if !screenTime.isAuthorized {
                                await screenTime.requestAuthorization()
                            }
                            showPicker = true
                        }
                    },
                    onNext: { currentStep = 7 }
                )
            case 7:
                OnboardingStep6_1View(onNext: { currentStep = 8 })
            case 8:
                OnboardingStep7View(onFinish: { state.completeOnboarding() })
            default:
                OnboardingStep1View(onNext: { currentStep = 2 })
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentStep)
        .familyActivityPicker(
            headerText: "Pick Social, Games and Entertainment — or individual apps.",
            isPresented: $showPicker,
            selection: $screenTime.selection
        )
        .onChange(of: showPicker) { _, isShowing in
            guard !isShowing else { return }
            screenTime.persistSelection()
            currentStep = 7
        }
    }
}

// MARK: - iPhone Frame Wrapper Component with Overlapping Support

struct iPhoneFrameView<Content: View, Overlay: View>: View {
    let content: Content
    let overlay: Overlay

    init(@ViewBuilder content: () -> Content, @ViewBuilder overlay: () -> Overlay = { EmptyView() }) {
        self.content = content()
        self.overlay = overlay()
    }

    var body: some View {
        ZStack {
            // Content sitting inside the iPhone screen bounds
            content
                .frame(width: 195, height: 420)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))

            // Real iPhone 17 Pro Max Frame Overlay
            Image("iPhoneMockup")
                .resizable()
                .scaledToFit()
                .frame(width: 230)
                .shadow(color: .black.opacity(0.12), radius: 14, x: 0, y: 6)
                .allowsHitTesting(false)

            // Overlapping Card popping out of the mockup frame
            overlay
        }
    }
}

// MARK: - Step 1: Welcome

struct OnboardingStep1View: View {
    let onNext: () -> Void

    private var artwork: Image {
        if UIImage(named: "Onboard1") != nil {
            return Image("Onboard1")
        } else if let sailor = UIImage(named: "Sailor1") {
            return Image(uiImage: sailor)
        } else {
            return Image(systemName: "person.crop.circle.fill")
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Character artwork from Onboard/1
            artwork
                .resizable()
                .scaledToFit()
                .frame(width: 240, height: 240)

            Spacer()

            // Titles
            VStack(spacing: 12) {
                Text("Welcome to Redire!")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)

                Text("A calmer way to balance work and breaks. Stay focused, take breaks on your terms, and find your way back.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)

            // Button
            Button(action: onNext) {
                Text("Next")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color(red: 29/255, green: 100/255, blue: 104/255), in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Step 2: Set your break freely!

struct OnboardingStep2View: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // iPhone Mockup with Time Picker Card overlapping out
            iPhoneFrameView(content: {
                Color(.systemGroupedBackground)
            }, overlay: {
                HStack(spacing: 8) {
                    VStack {
                        Text("14").font(.caption).foregroundStyle(.secondary)
                        Text("15").font(.title.bold()).foregroundStyle(.primary)
                        Text("16").font(.caption).foregroundStyle(.secondary)
                    }
                    Text("min").font(.subheadline).foregroundStyle(.secondary)

                    Text(":").font(.title.bold())

                    VStack {
                        Text("59").font(.caption).foregroundStyle(.secondary)
                        Text("00").font(.title.bold()).foregroundStyle(.primary)
                        Text("01").font(.caption).foregroundStyle(.secondary)
                    }
                    Text("sec").font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(.vertical, 22)
                .padding(.horizontal, 28)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .background(Color.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 6)
                .frame(width: 255)
            })

            Spacer()

            // Titles
            VStack(spacing: 12) {
                Text("Set your break freely!")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)

                Text("Take a break whenever you need. Set how long you'll be away and what you'll work on when you're back.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)

            // Button
            Button(action: onNext) {
                Text("Next")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color(red: 29/255, green: 100/255, blue: 104/255), in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Step 3: Return on time, Catch more

struct OnboardingStep3View: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // iPhone Mockup with Lockscreen Notifications overlapping
            iPhoneFrameView(content: {
                VStack {
                    VStack(spacing: 2) {
                        Text("Tue, 20 Apr").font(.caption2.weight(.medium)).foregroundStyle(.secondary)
                        Text("9:41").font(.system(size: 38, weight: .bold)).foregroundStyle(.primary.opacity(0.8))
                    }
                    .padding(.top, 40)
                    Spacer()
                }
            }, overlay: {
                VStack(spacing: 10) {
                    // Success Notification
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color(red: 210/255, green: 232/255, blue: 235/255))
                            .frame(width: 32, height: 32)
                            .overlay(Image(systemName: "fish.fill").font(.system(size: 14)).foregroundStyle(Color(red: 29/255, green: 100/255, blue: 104/255)))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("You got a fish!")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.primary)
                            Text("You made it back on time and earned yourself a fresh catch")
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .background(Color.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)

                    // Missed Notification
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 32, height: 32)
                            .overlay(Image(systemName: "fish.fill").font(.system(size: 14)).foregroundStyle(.gray))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Oops, you lost the fish")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.primary)
                            Text("You chose scrolling over sailing. Your catch has officially swum away")
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .background(Color.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                }
                .frame(width: 250)
                .offset(y: 35)
            })

            Spacer()

            // Titles
            VStack(spacing: 12) {
                Text("Return on time, Catch more")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)

                Text("Return to work on time to catch fish and unlock badges along the way")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)

            // Button
            Button(action: onNext) {
                Text("Next")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color(red: 29/255, green: 100/255, blue: 104/255), in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Step 4: If you stay away too long...

struct OnboardingStep4View: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // iPhone Mockup with Dynamic Island popup overlapping
            iPhoneFrameView(content: {
                Color(.systemGroupedBackground)
            }, overlay: {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Time is up!")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                    Text("It's time to do Creating Pitch Deck!")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.8))

                    HStack(spacing: 6) {
                        Capsule()
                            .fill(Color(red: 29/255, green: 100/255, blue: 104/255))
                            .frame(height: 3)
                        Image(systemName: "house.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.white)
                    }

                    HStack(spacing: 6) {
                        Text("Dismiss")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color(red: 245/255, green: 80/255, blue: 100/255))
                            .frame(maxWidth: .infinity, minHeight: 28)
                            .background(Color(.systemBackground), in: Capsule())

                        Text("Continue to work")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 28)
                            .background(Color(red: 29/255, green: 100/255, blue: 104/255), in: Capsule())
                    }
                }
                .padding(14)
                .background(Color.black, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: .black.opacity(0.2), radius: 14, x: 0, y: 6)
                .frame(width: 245)
            })

            Spacer()

            // Titles
            VStack(spacing: 12) {
                Text("If you stay away too long...")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)

                Text("Dismiss the reminder or stay away too long, and you'll miss your catch.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)

            // Button
            Button(action: onNext) {
                Text("Next")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color(red: 29/255, green: 100/255, blue: 104/255), in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Step 5: Last thing before you start

struct OnboardingStep5View: View {
    let onConfirm: () -> Void
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Permission Request Card Mockup with Teal Border Frame
            VStack(spacing: 14) {
                Text("“Redire” Would Like to Access Screen Time")
                    .font(.system(size: 13, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)

                Text("Providing “Redire” access to Screen Time may allow it to see your activity data, restrict content, and limit the usage of Apps & Websites.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)

                HStack(spacing: 10) {
                    Button(action: onConfirm) {
                        Text("Confirm")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, minHeight: 36)
                            .background(Color(.systemGray5), in: Capsule())
                    }
                    .buttonStyle(.plain)

                    Button(action: onNext) {
                        Text("Don’t Allow")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 36)
                            .background(Color.blue, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(18)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color(red: 29/255, green: 100/255, blue: 104/255).opacity(0.4), lineWidth: 2))
            .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 6)
            .padding(.horizontal, 28)

            Spacer()

            // Titles
            VStack(spacing: 12) {
                Text("Last thing before you start")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)

                Text("We'll need notifications to call you back, and app access to help you land your catch on time. All private, all on-device.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)

            // Button
            Button(action: onConfirm) {
                Text("Grant Access & Next")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color(red: 29/255, green: 100/255, blue: 104/255), in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Step 6: Know your distractions

struct OnboardingStep6View: View {
    let onAddApp: () -> Void
    let onNext: () -> Void

    private let categories: [String] = [
        "All Apps & Categories", "Social", "Games", "Entertainment", "Creativity", "Education"
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Category List Card Mockup floating over gray container
            VStack(spacing: 0) {
                ForEach(categories, id: \.self) { item in
                    categoryRow(item)
                    if item != "Education" { Divider() }
                }
            }
            .padding(.vertical, 6)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(12)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
            .padding(.horizontal, 28)

            Spacer()

            // Titles
            VStack(spacing: 12) {
                Text("Know your distractions")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)

                Text("Choose the apps that tend to pull you of course during your breaks.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)

            // Button
            Button(action: onAddApp) {
                Text("Add App")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color(red: 29/255, green: 100/255, blue: 104/255), in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .background(Color(.systemBackground))
    }

    private func categoryRow(_ item: String) -> some View {
        HStack {
            Image(systemName: "circle")
                .foregroundStyle(.gray)
            Text(item)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

// MARK: - Step 6.1: Choose Activities Picker

struct OnboardingStep6_1View: View {
    let onNext: () -> Void

    private let categories: [String] = [
        "All Apps & Categories", "Social", "Games", "Entertainment", "Creativity",
        "Education", "Health & Fitness", "Information & Reading", "Productivity & Finance",
        "Shopping & Food", "Travel"
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header bar
            HStack {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 32, height: 32)
                    .background(Color(.systemGray5), in: Circle())

                Spacer()

                Text("Choose Activities")
                    .font(.headline)

                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.blue)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 16)

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.gray)
                Text("Search")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                Spacer()
                Image(systemName: "mic.fill")
                    .foregroundStyle(.gray)
            }
            .padding(10)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            // List of App Categories
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(categories, id: \.self) { cat in
                        pickerRow(cat)
                        Divider().padding(.leading, 48)
                    }
                }
            }

            // Bottom action
            Button(action: onNext) {
                Text("Next")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color(red: 29/255, green: 100/255, blue: 104/255), in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .background(Color(.systemBackground))
    }

    private func pickerRow(_ cat: String) -> some View {
        HStack {
            Image(systemName: "circle")
                .foregroundStyle(.gray)
            Text(cat)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
    }
}

// MARK: - Step 7: You are all set!

struct OnboardingStep7View: View {
    let onFinish: () -> Void

    private var artwork: Image {
        if UIImage(named: "Onboard7") != nil {
            return Image("Onboard7")
        } else if let sailor = UIImage(named: "Sailor7") {
            return Image(uiImage: sailor)
        } else {
            return Image(systemName: "hand.thumbsup.circle.fill")
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // iPhone Mockup with Character Onboard7 emerging out
            iPhoneFrameView(content: {
                Color(.systemGroupedBackground)
            }, overlay: {
                artwork
                    .resizable()
                    .scaledToFit()
                    .frame(width: 210, height: 210)
                    .offset(y: -10)
            })

            Spacer()

            // Titles
            VStack(spacing: 12) {
                Text("You are all set!")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)

                Text("our journey starts here. Let's build better work and break habits, one return at a time")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)

            // Button
            Button(action: onFinish) {
                Text("Get Started")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color(red: 29/255, green: 100/255, blue: 104/255), in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Individual Previews for all 8 Steps

#Preview("1 - Welcome") {
    OnboardingStep1View(onNext: {})
}

#Preview("2 - Set Break Freely") {
    OnboardingStep2View(onNext: {})
}

#Preview("3 - Return On Time") {
    OnboardingStep3View(onNext: {})
}

#Preview("4 - If You Stay Away") {
    OnboardingStep4View(onNext: {})
}

#Preview("5 - Permission Request") {
    OnboardingStep5View(onConfirm: {}, onNext: {})
}

#Preview("6 - Know Your Distractions") {
    OnboardingStep6View(onAddApp: {}, onNext: {})
}

#Preview("6.1 - Choose Activities") {
    OnboardingStep6_1View(onNext: {})
}

#Preview("7 - You Are All Set") {
    OnboardingStep7View(onFinish: {})
}
