//
//  EditMedicalInstitutionView.swift
//  Home Karte
//
//  Created by Shota Sunohara on 2025/03/08.
//

import SwiftUI
import SwiftData

struct EditMedicalInstitutionView: View {
    @Bindable var medicalInstitution: MedicalInstitution
    @Environment(\.dismiss) var dismiss

    var isSaveDisabled: Bool {
        medicalInstitution.hospitalName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        medicalInstitution.doctorName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("🧑‍⚕️ 医療機関・医師情報")) {
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
            .navigationTitle("医療機関を編集")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("更新") {
                        try? medicalInstitution.modelContext?.save() // SwiftDataに変更を保存
                        dismiss()
                    }
                    .disabled(isSaveDisabled) // 入力チェック
                }
            }
        }
    }
}

