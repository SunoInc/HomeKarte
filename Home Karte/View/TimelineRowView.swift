//
//  TimelineRowView.swift
//  Home Karte
//
//  Created by Shota Sunohara on 2025/03/05.
//

import SwiftUI
import SwiftData

struct TimelineRowView: View {
    @Bindable var medicalInstitution: MedicalInstitution
    @Query private var appointments: [Appointment]

    init(medicalInstitution: MedicalInstitution) {
        self.medicalInstitution = medicalInstitution
        let medicalInstitutionID = medicalInstitution.id
        let predicate = #Predicate<Appointment> { appointment in
            appointment.medicalInstitutionID == medicalInstitutionID
        }
        _appointments = Query(filter: predicate, sort: \.date)
    }

    // 次回の診療予約を取得
    var nextAppointment: Appointment? {
        appointments.min(by: { $0.date < $1.date })
    }

    // 診療予約の状態に応じたテキスト
    var nextAppointmentText: String {
        if let nextAppointment = nextAppointment {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年M月d日（E） HH:mm"
            formatter.locale = Locale(identifier: "ja_JP")
            return "次回の診療予約：\(formatter.string(from: nextAppointment.date))"
        } else {
            return "次回の診療予約：まだ設定されていません"
        }
    }

    // アイコンの色を決定
    var appointmentStatusColor: Color {
        if let nextAppointment = nextAppointment {
            let calendar = Calendar.current
            let now = Date()
            
            if calendar.isDateInToday(nextAppointment.date) {
                return .green  // 診療予約が当日の場合
            } else if nextAppointment.date < now {
                return .red    // 診療予約が今日を過ぎている場合
            } else {
                return .yellow // 診療予約がある場合
            }
        } else {
            return .gray // 診療予約がない場合
        }
    }

    var body: some View {
        NavigationLink(destination: AppointmentView(medicalInstitution: medicalInstitution)) {
            VStack {
                HStack {
                    Image("99")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())

                    VStack(alignment: .leading) {
                        Text(medicalInstitution.hospitalName)
                            .font(.headline)
                            .lineLimit(1)
                        Text(medicalInstitution.doctorName)
                            .font(.subheadline)
                            .lineLimit(1)
                        Text(medicalInstitution.specialty)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    .padding(.leading, 8)

                    Spacer()
                }

                if let _ = nextAppointment {
                    Divider()
                        .frame(width: 200, height: 10)
                    
                    HStack {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 8, height: 8)
                            .foregroundColor(appointmentStatusColor) // 状態に応じた色
                        Text(nextAppointmentText)
                            .font(.caption)
                            .foregroundColor(nextAppointment == nil ? .secondary : .primary)
                        Spacer()
                    }
                    .padding(.top, 5)
                    .frame(maxWidth: .infinity)
                }

            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
