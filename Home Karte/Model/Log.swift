//
//  Log.swift
//  Home Karte
//
//  Created by Shota Sunohara on 2025/02/08.
//

import Foundation
import SwiftData

@Model
final class Log: Identifiable {
    var id = UUID()
    var hospital: String
    var status: String
    var note: String
    var imageStrings: [String]
    var date: Date
    var medicalExpense: String // 支払った金額
    var insuranceCoverage: String // 保険金額（補填される金額）
    var transportationCost: String // 交通費
    var transportationMethod: String // 交通手段
    var route: String // ルート

    
    init(id: UUID = UUID(), hospital: String, status: String, note: String, date: Date = Date(), imageStrings: [String] = [], medicalExpense: String = "", insuranceCoverage: String = "",
         transportationCost: String = "", transportationMethod: String = "", route: String = "") {
        self.id = id
        self.hospital = hospital
        self.status = status
        self.note = note
        self.imageStrings = imageStrings
        self.date = date
        self.medicalExpense = medicalExpense
        self.insuranceCoverage = insuranceCoverage
        self.transportationCost = transportationCost
        self.transportationMethod = transportationMethod
        self.route = route

    }
    
}

extension Log {
    static var emptyList: [Log] {[]}
    static var mockData: [Log] {
        [
            Log(hospital: "まるまる病院", status: "腹痛", note: "備考", date: Date(timeIntervalSinceNow: -86400 * 3), imageStrings: ["image1_base64", "image2_base64"]),
            Log(hospital: "さんかく病院", status: "足痛", note: "備考", date: Date(timeIntervalSinceNow: -86400 * 7), imageStrings: ["image3_base64"]),
            Log(hospital: "しかく病院", status: "膝痛", note: "備考", date: Date(timeIntervalSinceNow: -86400 * 30))
        ]
    }
}

extension String {
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
