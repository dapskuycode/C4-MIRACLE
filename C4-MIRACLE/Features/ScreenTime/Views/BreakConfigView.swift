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
    private var isValid: Bool { BreakDurations.range.contains(totalSeconds) }

    /// iOS did not identify the app, so nothing can be derived to reopen it. The break still
    /// applies — it just ends with the user back here rather than back in the app.
    private var unresolved: Bool {
        AppLaunchService.isUnresolved(name: request.appName, bundleID: request.appBundleID)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    artwork
                    header
                    durationPicker
                    nextTaskField
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .scrollBounceBehavior(.basedOnSize)

            actions
        }
        .background(Color(.systemBackground))
        .interactiveDismissDisabled(isSaving)
    }

    // MARK: - Sections

    private var artwork: some View {
        // Generated asset symbol rather than a string, so a renamed asset breaks the build
        // instead of silently rendering nothing.
        Image(.fishing)
            .resizable()
            .scaledToFit()
            .frame(maxHeight: 180)
            .accessibilityHidden(true)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("Before you go")
                .font(.title.bold())
                .foregroundStyle(BrandColors.ink)

            if unresolved {
                Text("iOS didn't identify this app, so it can't be reopened automatically. Your break still applies to every blocked app.")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .multilineTextAlignment(.center)
            }
        }
    }

    /// Two wheels rather than a stepper, because the design asks for one.
    ///
    /// The value is still a plain second count — `BreakDurations` and the DeviceActivity
    /// scheduling underneath are unchanged.
    private var durationPicker: some View {
        VStack(spacing: 4) {
            HStack(spacing: 10) {
                wheel(value: $minutes, range: 0...180, unit: "min")
                Text(":")
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(BrandColors.ink)
                wheel(value: $seconds, range: 0...59, unit: "sec")
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .padding(.horizontal, 12)

            if totalSeconds < BreakDurations.developmentCeiling {
                Text("Under a minute is for testing. The usage-based re-block can't be armed below one minute — DeviceActivity thresholds are whole minutes — so a break this short relies on the wall clock alone.")
                    .font(.caption2)
                    .foregroundStyle(BrandColors.muted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
            }
        }
        .background(BrandColors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    /// `.center` alignment, not `.firstTextBaseline`: a wheel picker's baseline sits at the
    /// top of its rotating drum, which pushed the unit label up above the numbers.
    private func wheel(value: Binding<Int>, range: ClosedRange<Int>, unit: String) -> some View {
        HStack(alignment: .center, spacing: 6) {
            Picker(unit, selection: value) {
                ForEach(Array(range), id: \.self) { number in
                    Text(String(format: "%02d", number))
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .tag(number)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(width: 86)
            .clipped()

            Text(unit)
                .font(.footnote)
                .foregroundStyle(BrandColors.muted)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(unit == "min" ? "Minutes" : "Seconds")
    }

    private var nextTaskField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Next task after break time")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BrandColors.ink)

            TextField("Next Task", text: $nextTask, axis: .vertical)
                .lineLimit(1...3)
                .padding(14)
                .frame(minHeight: 44)
                .background(BrandColors.surface,
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actions: some View {
        HStack(spacing: 12) {
            Button {
                state.dismissRequest()
                dismiss()
            } label: {
                Text("Cancel")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(BrandColors.muted)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(BrandColors.surface,
                                in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)

            Button(action: save) {
                HStack(spacing: 8) {
                    Text("Take a Break")
                    if isSaving { ProgressView().tint(BrandColors.onAccent) }
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(BrandColors.onAccent)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(BrandColors.accent.opacity(isValid && !isSaving ? 1 : 0.4),
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!isValid || isSaving)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.bar)
    }

    // MARK: -

    private func save() {
        isSaving = true
        // Commit, close the sheet, *then* launch. See AppState for why the launch cannot
        // happen in the same breath as the unshield.
        state.commitBreak(request: request, seconds: totalSeconds, nextTask: nextTask)
        dismiss()
        Task {
            await state.openRequestedApp(request)
            isSaving = false
        }
    }
}
