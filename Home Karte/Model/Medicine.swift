//
//  Medicine.swift
//  Home Karte
//
//  Created by Shota Sunohara on 2025/02/15.
//

import Foundation
import SwiftData

enum ScheduleType: String, CaseIterable, Codable {
    case everyDay = "毎日"
    case specificDays = "特定の曜日"
    case interval = "数日おき"
    case periodic = "周期的なスケジュール"
    case asNeeded = "必要なとき"

    var localizedName: String {
        return self.rawValue
    }
}


@Model
class Medicine {
    var id: UUID = UUID() // @Attribute(.unique) は不要
    var name: String
    var type: String
    var activeIngredientAmount: String
    var unit: String
    var scheduleType: ScheduleType
    var intervalDays: Int
    var medicationPeriod: Int
    var restPeriod: Int
    var startDate: Date
    var endDate: Date?
    var sideEffects: String

    // selectedDaysとselectedTimesを適切な型で定義
    var selectedDays: [Int] = []
    var selectedTimes: [Date] = []
    
    var isReminderOn: Bool = false
    var isTaking: Bool = false

    init(
        name: String,
        type: String = "カプセル",
        activeIngredientAmount: String = "",
        unit: String = "mg",
        scheduleType: ScheduleType = .everyDay,
//        scheduleType: String = "毎日",
        intervalDays: Int = 1,
        medicationPeriod: Int = 7,
        restPeriod: Int = 7,
        startDate: Date = Date(),
        endDate: Date? = nil,
        sideEffects: String = "",
        isReminderOn: Bool = false,
        isTaking: Bool = false
    ) {
        self.name = name
        self.type = type
        self.activeIngredientAmount = activeIngredientAmount
        self.unit = unit
        self.scheduleType = scheduleType
        self.intervalDays = intervalDays
        self.medicationPeriod = medicationPeriod
        self.restPeriod = restPeriod
        self.startDate = startDate
        self.endDate = endDate
        self.sideEffects = sideEffects
        self.isReminderOn = isReminderOn
        self.isTaking = isTaking
    }
}

extension ScheduleType {
    static func fromString(_ value: String) -> ScheduleType {
        return ScheduleType(rawValue: value) ?? .everyDay
    }
}
