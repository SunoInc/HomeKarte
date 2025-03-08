//
//  AddMedicalInstitutionView.swift
//  Home Karte
//
//  Created by Shota Sunohara on 2025/03/05.
//

import SwiftUI
import SwiftData

struct AddMedicalInstitutionView: View {
    
    @Bindable var medicalInstitution: MedicalInstitution
    
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    
    @State private var hospitalName = ""
    @State private var doctorName = ""
    @State private var specialty = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var postalCode = ""
    @State private var prefecture = ""
    @State private var city = ""
    @State private var address = ""
    
    var isSaveDisabled: Bool {
        medicalInstitution.hospitalName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        medicalInstitution.doctorName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("🧑‍⚕️医療機関・医師情報")) {
                    TextField("医療機関名", text: $medicalInstitution.hospitalName)
                    TextField("医師の名前", text: $medicalInstitution.doctorName)
                    TextField("専門分野", text: $medicalInstitution.specialty)
                }
                
                Section(header: Text("連絡先")) {
                    TextField("電話番号", text: $medicalInstitution.phoneNumber)
                        .keyboardType(.phonePad)
                    TextField("メールアドレス", text: $medicalInstitution.email)
                        .keyboardType(.emailAddress)
                }
                
                Section(header: Text("住所")) {
                    TextField("郵便番号", text: $medicalInstitution.postalCode)
                    TextField("都道府県", text: $medicalInstitution.prefecture)
                    TextField("市町村", text: $medicalInstitution.city)
                    TextField("番地", text: $medicalInstitution.address)
                }
            }
            .navigationTitle("医療機関・医師を追加")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        _ = MedicalInstitution(
                            hospitalName: hospitalName,
                            doctorName: doctorName,
                            specialty: specialty,
                            phoneNumber: phoneNumber,
                            email: email,
                            postalCode: postalCode,
                            prefecture: prefecture,
                            city: city,
                            address: address
                        )
                            context.insert(medicalInstitution)
                            dismiss()
                    }
                    .disabled(isSaveDisabled)
                }
            }
        }
    }
}
