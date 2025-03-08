//
//  CompletedScheduleView.swift
//  Home Karte
//
//  Created by Shota Sunohara on 2025/03/06.
//

import SwiftUI
import SwiftData

struct CompletedScheduleView: View {
    var completedAppointments: [Appointment]  // 完了した予定のリストを外部から受け取る

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }

    var body: some View {
        VStack {
            Text("過去の予定一覧")
                .font(.title)
                .padding()
            
            Divider()
                .frame(width: 200, height: 20)

            if completedAppointments.isEmpty {
                Text("完了した予定はありません")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List(completedAppointments) { appointment in
                    HStack {
                        Text(dateFormatter.string(from: appointment.date)) // 日付
                            .foregroundColor(.primary)
                        Spacer()
                        Text(appointment.date, format: .dateTime.hour().minute()) // 時間
                            .foregroundColor(.primary)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}
