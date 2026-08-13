//
//  AchievementView.swift
//  C4-MIRACLE
//
//  Features — Achievement
//

import SwiftUI

// MARK: - Dummy Data Model

struct DummyBadge: Identifiable {
    let id: String
    let name: String
    let description: String
    let imageName: String
    let sfSymbol: String?
    let goal: Int
    let current: Int
    let firstCaughtDate: Date?

    var isUnlocked: Bool { current >= goal }
    var progress: Double { min(Double(current) / Double(goal), 1.0) }
}

let dummyBadges: [DummyBadge] = [
    DummyBadge(
        id: "masterAngler",
        name: "Master Angler",
        description: "You caught 10 fish by successfully returning to work after your breaks.",
        imageName: "SettingSummary_Badge_Active_MasterAngler",
        sfSymbol: nil,
        goal: 10,
        current: 10,
        firstCaughtDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())
    ),
    DummyBadge(
        id: "stormChaser",
        name: "Storm Chaser",
        description: "You found your way back after a missed return, proving that one rough tide won't stop your journey.",
        imageName: "Badge_Inactive_StormChaser",
        sfSymbol: nil,
        goal: 5,
        current: 2,
        firstCaughtDate: nil
    ),
    DummyBadge(
        id: "steadySailor",
        name: "Steady Sailor",
        description: "You returned to work on time for 3 consecutive days, showing the start of a consistent routine.",
        imageName: "Badge_Inactive_SteadySailor",
        sfSymbol: nil,
        goal: 7,
        current: 3,
        firstCaughtDate: nil
    ),
    DummyBadge(
        id: "trueNavigator",
        name: "True Navigator",
        description: "You completed 5 work sessions without dismissing your break reminder, staying committed to your course.",
        imageName: "Badge_Inactive_TrueNavigator",
        sfSymbol: nil,
        goal: 50,
        current: 10,
        firstCaughtDate: nil
    ),
    DummyBadge(
        id: "fullSail",
        name: "Full Sail",
        description: "You completed 3 work sessions in one day, making the most of your working hours.",
        imageName: "",
        sfSymbol: "sailboat.fill",
        goal: 100,
        current: 10,
        firstCaughtDate: nil
    ),
]

// MARK: - Achievement View

struct AchievementView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var selectedBadge: DummyBadge? = nil

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 28) {
                ForEach(dummyBadges) { badge in
                    BadgeCell(badge: badge)
                        .onTapGesture { selectedBadge = badge }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Your Achievement")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedBadge) { badge in
            BadgeDetailView(badge: badge)
        }
    }
}

// MARK: - Badge Cell

struct BadgeCell: View {
    let badge: DummyBadge

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if !badge.imageName.isEmpty, UIImage(named: badge.imageName) != nil {
                    Image(badge.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 78, height: 78)
                        .grayscale(badge.isUnlocked ? 0 : 0.8)
                        .opacity(badge.isUnlocked ? 1.0 : 0.85)
                        .shadow(
                            color: badge.isUnlocked
                                ? Color(red: 29/255, green: 100/255, blue: 104/255).opacity(0.2)
                                : .clear,
                            radius: 8, x: 0, y: 4
                        )
                } else {
                    Circle()
                        .fill(badge.isUnlocked
                              ? Color(red: 210/255, green: 232/255, blue: 235/255)
                              : Color(.systemGray5))
                        .frame(width: 78, height: 78)
                        .shadow(
                            color: badge.isUnlocked
                                ? Color(red: 29/255, green: 100/255, blue: 104/255).opacity(0.18)
                                : .clear,
                            radius: 8, x: 0, y: 4
                        )

                    if let symbol = badge.sfSymbol {
                        Image(systemName: symbol)
                            .font(.system(size: 34, weight: .medium))
                            .foregroundStyle(badge.isUnlocked
                                             ? Color(red: 29/255, green: 100/255, blue: 104/255)
                                             : Color(.systemGray3))
                    }
                }
            }

            Text(badge.name)
                .font(.caption.weight(.semibold))
                .foregroundStyle(badge.isUnlocked ? .primary : Color(.systemGray2))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            if badge.isUnlocked {
                Text("Unlocked!")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color(red: 29/255, green: 100/255, blue: 104/255))
            } else {
                Text("\(badge.current) of \(badge.goal)")
                    .font(.caption2)
                    .foregroundStyle(Color(.systemGray3))
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Badge Detail View

struct BadgeDetailView: View {

    let badge: DummyBadge
    @Environment(\.dismiss) private var dismiss

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "d MMMM yyyy"
        return f
    }

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 16)

            // Close button (X) top right
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                        .background(Color(.systemGray5), in: Circle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)

            // Large Badge Image
            ZStack {
                if !badge.imageName.isEmpty, UIImage(named: badge.imageName) != nil {
                    Image(badge.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)
                        .grayscale(badge.isUnlocked ? 0 : 0.8)
                        .opacity(badge.isUnlocked ? 1.0 : 0.85)
                        .shadow(
                            color: badge.isUnlocked
                                ? Color(red: 29/255, green: 100/255, blue: 104/255).opacity(0.25)
                                : .clear,
                            radius: 16, x: 0, y: 6
                        )
                } else {
                    Circle()
                        .fill(badge.isUnlocked
                              ? Color(red: 210/255, green: 232/255, blue: 235/255)
                              : Color(.systemGray5))
                        .frame(width: 140, height: 140)
                        .shadow(
                            color: badge.isUnlocked
                                ? Color(red: 29/255, green: 100/255, blue: 104/255).opacity(0.2)
                                : .clear,
                            radius: 16, x: 0, y: 6
                        )

                    if let symbol = badge.sfSymbol {
                        Image(systemName: symbol)
                            .font(.system(size: 54, weight: .medium))
                            .foregroundStyle(badge.isUnlocked
                                             ? Color(red: 29/255, green: 100/255, blue: 104/255)
                                             : Color(.systemGray3))
                    }
                }
            }
            .padding(.bottom, 24)

            // Badge Name
            Text(badge.name)
                .font(.title2.bold())
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
                .padding(.horizontal, 24)

            // Description Card
            Text(badge.description)
                .font(.subheadline)
                .foregroundStyle(Color(.darkGray))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.vertical, 18)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

            // Bottom status: unlock date or locked status text
            if let date = badge.firstCaughtDate {
                Text("First caught on \(dateFormatter.string(from: date))")
                    .font(.caption)
                    .foregroundStyle(Color(.systemGray2))
            } else {
                Text("You blm pernah dapet enih")
                    .font(.caption)
                    .foregroundStyle(Color(.systemGray3))
            }

            Spacer()
        }
        .background(Color(.systemBackground))
        .presentationDetents([.large])
        .presentationCornerRadius(28)
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

// MARK: - Preview

#Preview("Achievement List") {
    NavigationStack {
        AchievementView()
    }
}

#Preview("Badge Detail - Unlocked") {
    BadgeDetailView(badge: dummyBadges[0])
}

#Preview("Badge Detail - Locked") {
    BadgeDetailView(badge: dummyBadges[1])
}
