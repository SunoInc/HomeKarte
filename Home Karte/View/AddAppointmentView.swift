//
//  AddAppointmentView.swift
//  Home Karte
//
//  Created by Shota Sunohara on 2025/03/06.
//

import SwiftUI
import SwiftData

struct AddAppointmentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var medicalInstitution: MedicalInstitution
    var appointment: Appointment? // 編集する予約データ

    @State private var selectedDate = Date()
    @State private var memo = ""
    
    @State private var showDatePicker = false
    @State private var showTimePicker = false

    // 日付の表示形式を設定
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }

    // 編集の場合、予約データをセット
    private func setupInitialValues() {
        if let appointment = appointment {
            selectedDate = appointment.date
            memo = appointment.memo
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("診療予定")) {
                    Button(action: {
                        showDatePicker.toggle()
                    }) {
                        HStack {
                            Text("日付を選択")
                            Spacer()
                            Text(dateFormatter.string(from: selectedDate))
                                .foregroundColor(.blue)
                        }
                    }
                    if showDatePicker {
                        VStack {
                            DatePicker("日付を選択", selection: $selectedDate, displayedComponents: [.date])
                                .datePickerStyle(.graphical)
                            
                            Button("保存") {
                                showDatePicker = false
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.top, 8)
                        }
                    }
                    
                    Button(action: {
                        showTimePicker.toggle()
                    }) {
                        HStack {
                            Text("時間を選択")
                            Spacer()
                            Text(selectedDate, format: .dateTime.hour().minute())
                                .foregroundColor(.blue)
                        }
                    }
                    if showTimePicker {
                        VStack {
                            DatePicker("時間を選択", selection: $selectedDate, displayedComponents: [.hourAndMinute])
                                .datePickerStyle(.wheel)

                            Button("保存") {
                                showTimePicker = false
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.top, 8)
                        }
                    }
                }

                Section(header: Text("メモ")) {
                    TextEditor(text: $memo)
                        .frame(height: 100)
                }
            }
            .scrollContentBackground(.hidden) // Form のデフォルト背景を削除
            .background(Color("BackgroundLightPurple"))
            .navigationTitle(appointment == nil ? "診療予約を追加" : "診療予約を編集")
            .onAppear {
                setupInitialValues() // 予約データの初期設定
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(appointment == nil ? "追加" : "更新") {
                        let newAppointment = Appointment(
                            date: selectedDate,
                            memo: memo,
                            medicalInstitutionID: medicalInstitution.id
                        )
                        
                        if let existingAppointment = appointment {
                            // 既存の予約を更新
                            existingAppointment.date = selectedDate
                            existingAppointment.memo = memo
                        } else {
                            // 新規予約の追加
                            modelContext.insert(newAppointment)
                        }
                        
                        dismiss()
                    }
                }
            }
        }
        .background(Color("BackgroundLightPurple"))
    }
}
