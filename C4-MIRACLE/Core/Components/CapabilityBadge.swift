//
//  CapabilityBadge.swift
//  C4-MIRACLE
//
//  Core — Components
//

import SwiftUI

/// Honesty labels, shown throughout the Screen Time UI so it is always clear which parts of
/// the flow iOS genuinely supports.
///
/// The one piece of reusable UI the proof of concept actually had — used by the work mode,
/// break and setup screens. It is a development aid: consider dropping it once the feature
/// stops being something the team is still verifying against the OS.
enum Capability: String {
    case real      = "REAL"
    case partial   = "PARTIAL"
    case simulated = "SIMULATED"

    var color: Color {
        switch self {
        case .real:      return .green
        case .partial:   return .orange
        case .simulated: return .red
        }
    }
}

struct CapabilityBadge: View {

    let capability: Capability
    var note: String?

    var body: some View {
        HStack(spacing: 6) {
            Text(capability.rawValue)
                .font(.caption2.weight(.bold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(capability.color.opacity(0.18), in: Capsule())
                .foregroundStyle(capability.color)
            if let note {
                Text(note)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
