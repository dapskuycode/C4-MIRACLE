//
//  DeviceActivityNames.swift
//  C4-MIRACLE
//
//  Shared — Constants
//

import Foundation
import DeviceActivity

/// Names shared between the app (which starts monitoring) and the monitor extension
/// (which receives the callbacks). A mismatch means the callback silently never arrives.
extension DeviceActivityName {

    /// The window whose *start* is anchored to a break's expiry.
    ///
    /// A `DeviceActivitySchedule` interval must be at least 15 minutes, so "re-check in 5
    /// minutes" cannot be expressed as a window that *ends* then. Anchoring the start
    /// instead is what makes `intervalDidStart` fire at the right moment — see
    /// `BreakScheduler`.
    static let breakWindow = Self("MiracleBreakWindow")
}

extension DeviceActivityEvent.Name {

    /// Fires once the user has actually *used* the unlocked apps for the granted number of
    /// minutes. Measuring usage is arguably truer to what "a 5 minute break" means, and it
    /// sidesteps the 15-minute schedule minimum — but thresholds are whole minutes, so it
    /// cannot be armed for a sub-minute break.
    static let breakUsageLimit = Self("MiracleBreakUsageLimit")
}
