//
//  BreakConfigView.swift
//  C4-MIRACLE
//
//  Features — ScreenTime / Views
//

import SwiftUI

/// The screen the whole blocking concept is built around.
///
/// Note that this cannot be the shield itself — the shield is drawn by the system and supports
/// a title, subtitle and two buttons, nothing more. A duration wheel and a text field have to
/// live in the app, which is precisely why getting the user *into* the app is the hard part of
/// this problem.
struct BreakConfigView: View {

    let request: BreakRequest

    @EnvironmentObject private var state: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var minutes = 15
    @State private var seconds = 0
    @State private var nextTask = ""
    @State private var isSaving = false

    private var totalSeconds: Int { minutes * 60 + seconds }
    private var isTaskNotEmpty: Bool {
        !nextTask.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    private var isValid: Bool {
        totalSeconds > 0 && isTaskNotEmpty
    }

    /// iOS did not identify the app, so nothing can be derived to reopen it. The break still
    /// applies — it just ends with the user back here rather than back in the app.
    private var unresolved: Bool {
        AppLaunchService.isUnresolved(name: request.appName, bundleID: request.appBundleID)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Drag Indicator Handle
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 12)

            // Navigation Top Bar (X / Title / Up Arrow)
            topBar
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if unresolved {
                        Text("iOS didn't identify this app, so it can't be reopened automatically. Your break still applies to every blocked app.")
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }

                    // Section 1: Set Break Time
                    setBreakTimeSection

                    // Section 2: Next Task
                    nextTaskSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 28) // Push content down into a balanced centered position
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(Color.white)
        .interactiveDismissDisabled(isSaving)
    }

    // MARK: - Top Navigation Bar

    private var topBar: some View {
        HStack {
            // Left: Close X Button
            Button {
                state.dismissRequest()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(Color(red: 245/255, green: 245/255, blue: 247/255), in: Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            // Center Title
            Text("Plan Your Next Task")
                .font(.headline.bold())
                .foregroundStyle(.black)

            Spacer()

            // Right: Submit Up-Arrow Button
            Button(action: save) {
                ZStack {
                    Circle()
                        .fill(Color(red: 29/255, green: 100/255, blue: 104/255))
                        .frame(width: 44, height: 44)
                    
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(!isValid || isSaving)
            .opacity(isValid && !isSaving ? 1.0 : 0.4)
        }
    }

    // MARK: - Section 1: Set Break Time

    private var setBreakTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Set Break Time")
                .font(.title3.bold())
                .foregroundStyle(.black)

            VStack(spacing: 4) {
                HStack(spacing: 10) {
                    wheel(value: $minutes, range: 0...180, unit: "min")
                    Text(":")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.black)
                    wheel(value: $seconds, range: 0...59, unit: "sec")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 140)
                .padding(.horizontal, 12)

                if totalSeconds < BreakDurations.developmentCeiling {
                    Text("Under a minute is for testing. The usage-based re-block can't be armed below one minute — DeviceActivity thresholds are whole minutes — so a break this short relies on the wall clock alone.")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 12)
                }
            }
            .background(Color(red: 245/255, green: 245/255, blue: 247/255), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private func wheel(value: Binding<Int>, range: ClosedRange<Int>, unit: String) -> some View {
        HStack(alignment: .center, spacing: 6) {
            Picker(unit, selection: value) {
                ForEach(Array(range), id: \.self) { number in
                    Text(String(format: "%02d", number))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .tag(number)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(width: 86)
            .clipped()

            Text(unit)
                .font(.footnote)
                .foregroundStyle(.gray)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(unit == "min" ? "Minutes" : "Seconds")
    }

    // MARK: - Section 2: Next Task

    private var nextTaskSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Next Task")
                .font(.title3.bold())
                .foregroundStyle(.black)

            TextField("Creating Pitch Deck", text: $nextTask)
                .multilineTextAlignment(.leading)
                .font(.body)
                .foregroundStyle(.black)
                .padding(.horizontal, 16)
                .frame(height: 56)
                .background(Color(red: 245/255, green: 245/255, blue: 247/255), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    // MARK: - Save Logic

    private func save() {
        isSaving = true
        state.commitBreak(request: request, seconds: totalSeconds, nextTask: nextTask)
        dismiss()
        Task {
            await state.openRequestedApp(request)
            isSaving = false
        }
    }
}
