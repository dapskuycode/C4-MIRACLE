//
//  LocalNotificationService.swift
//  C4-MIRACLE
//
//  Shared — Services
//

import Foundation
import UserNotifications

enum LocalNotificationService {

    /// Posts notification when the user dismisses their break:
    /// Title: "Oops, you lost the fish"
    /// Body: "You chose scrolling over sailing. Your catch has officially swum away"
    static func sendDismissNotification() {
        send(
            title: "Oops, you lost the fish",
            body: "You chose scrolling over sailing. Your catch has officially swum away"
        )
    }

    /// Posts notification when the user taps Continue to Work:
    /// Title: "You got a fish!"
    /// Body: "You made it back on time and earned yourself a fresh catch"
    static func sendContinueToWorkNotification() {
        send(
            title: "You got a fish!",
            body: "You made it back on time and earned yourself a fresh catch"
        )
    }

    private static func send(title: String, body: String) {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }

            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default

            let request = UNNotificationRequest(
                identifier: "miracle.outcome.\(UUID().uuidString)",
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.2, repeats: false)
            )

            center.add(request) { error in
                if let error = error {
                    NSLog("[LocalNotificationService] FAILED: \(error)")
                } else {
                    NSLog("[LocalNotificationService] Sent: \(title)")
                }
            }
        }
    }
}
