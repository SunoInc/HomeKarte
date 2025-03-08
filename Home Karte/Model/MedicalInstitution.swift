//
//  Event.swift
//  Home Karte
//
//  Created by Shota Sunohara on 2025/02/22.
//

import Foundation
import SwiftData

@Model
final class MedicalInstitution: Identifiable {
    var id: UUID
    var hospitalName: String
    var doctorName: String
    var specialty: String
    var phoneNumber: String
    var email: String
    var postalCode: String
    var prefecture: String
    var city: String
    var address: String
    
    init(hospitalName: String, doctorName: String, specialty: String, phoneNumber: String, email: String, postalCode: String, prefecture: String, city: String, address: String) {
        self.id = UUID()
        self.hospitalName = hospitalName
        self.doctorName = doctorName
        self.specialty = specialty
        self.phoneNumber = phoneNumber
        self.email = email
        self.postalCode = postalCode
        self.prefecture = prefecture
        self.city = city
        self.address = address
    }
}
