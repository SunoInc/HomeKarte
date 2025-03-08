//
//  NotificationManager.swift
//  Home Karte
//
//  Created by Shota Sunohara on 2025/03/02.
//

import Foundation
import UserNotifications
import SwiftData

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    // 通知の許可をリクエスト
    func requestAuthorization() {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("通知の許可リクエストでエラー: \(error.localizedDescription)")
                } else {
                    print("通知の許可: \(granted ? "許可された" : "拒否された")")
                }
            }
        }
    
    // 通知をスケジュール
    func scheduleNotifications(for medicine: Medicine) {
        cancelNotifications(for: medicine) // 既存の通知を削除

        let center = UNUserNotificationCenter.current()

        for time in medicine.selectedTimes {
            let identifier = "medicine-\(medicine.id.uuidString)-\(time.timeIntervalSince1970)"

            let content = UNMutableNotificationContent()
            content.title = "服薬のお時間です！"
            content.body = "\(medicine.name) を忘れずに〜"
            content.sound = .default

            let trigger = createTrigger(for: medicine, at: time)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            center.add(request) { error in
                if let error = error {
                    print("通知のスケジュールエラー: \(error.localizedDescription)")
                }
            }
        }
    }

    // 通知のトリガーを作成
    private func createTrigger(for medicine: Medicine, at time: Date) -> UNCalendarNotificationTrigger {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)

        var dateComponents = DateComponents()
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute

        switch medicine.scheduleType {
        case .everyDay:
            return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        case .specificDays:
            return createDayBasedTrigger(for: medicine, timeComponents: dateComponents)
        case .interval:
            return createIntervalTrigger(for: medicine, timeComponents: dateComponents)
        case .periodic:
            return createPeriodicTrigger(for: medicine, timeComponents: dateComponents)
        case .asNeeded:
            return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        }
    }

    private func createDayBasedTrigger(for medicine: Medicine, timeComponents: DateComponents) -> UNCalendarNotificationTrigger {
        var dateComponents = timeComponents
        if let weekday = medicine.selectedDays.first {
            dateComponents.weekday = weekday
        }
        return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    }

    private func createIntervalTrigger(for medicine: Medicine, timeComponents: DateComponents) -> UNCalendarNotificationTrigger {
        let startDate = Calendar.current.startOfDay(for: medicine.startDate)
        let interval = medicine.intervalDays * 24 * 60 * 60
        let triggerDate = startDate.addingTimeInterval(TimeInterval(interval))
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        return UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
    }

    private func createPeriodicTrigger(for medicine: Medicine, timeComponents: DateComponents) -> UNCalendarNotificationTrigger {
        let startDate = Calendar.current.startOfDay(for: medicine.startDate)
        let period = (medicine.medicationPeriod + medicine.restPeriod) * 24 * 60 * 60
        let triggerDate = startDate.addingTimeInterval(TimeInterval(period))
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        return UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
    }

    // 通知をキャンセル
    func cancelNotifications(for medicine: Medicine) {
        let center = UNUserNotificationCenter.current()
        let identifiers = medicine.selectedTimes.map { "medicine-\(medicine.id.uuidString)-\($0.timeIntervalSince1970)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
