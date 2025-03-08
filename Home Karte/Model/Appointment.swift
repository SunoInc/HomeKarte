//
//  Appointment.swift
//  Home Karte
//
//  Created by Shota Sunohara on 2025/03/06.
//

import Foundation
import SwiftData

@Model
final class Appointment: Identifiable {
    var id: UUID
    var date: Date
    var memo: String
    var medicalInstitutionID: UUID  // MedicalInstitution の ID のみ保存

    init(date: Date, memo: String, medicalInstitutionID: UUID) {
        self.id = UUID()
        self.date = date
        self.memo = memo
        self.medicalInstitutionID = medicalInstitutionID
    }
}
