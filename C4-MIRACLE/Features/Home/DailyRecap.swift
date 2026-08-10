//
//  DailyRecap.swift
//  C4-MIRACLE
//
//  Features — Home
//

import Foundation

/// The two numbers on the home screen, counted from the breaks archived today.
///
/// Kept as a plain value rather than a view model: it derives entirely from
/// `SharedStore.grantHistory` and holds no state of its own, so there is nothing to observe.
struct DailyRecap: Equatable {

    /// Breaks the user closed themselves — either going back to work or ending early.
    var committed: Int
    /// Breaks that simply ran out. The apps stayed unlocked until something else intervened.
    var missedReturns: Int

    static let empty = DailyRecap(committed: 0, missedReturns: 0)

    /// - Note: `grantHistory` keeps only the last 20 breaks, so a very heavy day can undercount.
    ///   That ceiling lives in `SharedStore` and is deliberate — the App Group is not a database.
    static func today(from history: [BreakGrant] = SharedStore.grantHistory,
                      calendar: Calendar = .current,
                      now: Date = Date()) -> DailyRecap {
        let todays = history.filter { calendar.isDate($0.grantedAt, inSameDayAs: now) }
        return DailyRecap(
            committed: todays.filter { $0.outcome?.isCommitted == true }.count,
            missedReturns: todays.filter { $0.outcome == .expired }.count
        )
    }
}
