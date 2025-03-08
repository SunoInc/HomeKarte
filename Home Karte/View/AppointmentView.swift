//
//  AppointmentView.swift
//  Home Karte
//
//  Created by Shota Sunohara on 2025/03/06.
//

import SwiftUI
import SwiftData

struct AppointmentView: View {
    let medicalInstitution: MedicalInstitution
    @State private var showAddAppointmentSheet = false
    @State private var selectedAppointment: Appointment? = nil
    @State private var showDeleteAlert = false
    @State private var appointmentToDelete: Appointment? = nil
    @State private var showCompletedScheduleSheet = false
    @State private var showEditSheet = false
    
    @State private var completedAppointments: [Appointment] = [] // 完了した予定のリスト
    @Query private var appointments: [Appointment]
    
    @Environment(\.modelContext) private var modelContext // SwiftDataで使うmodelContextに変更

    init(medicalInstitution: MedicalInstitution) {
        self.medicalInstitution = medicalInstitution
        let medicalInstitutionID = medicalInstitution.id
        let predicate = #Predicate<Appointment> { appointment in
            appointment.medicalInstitutionID == medicalInstitutionID
        }
        _appointments = Query(filter: predicate, sort: \.date)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack {
                // Medical Institution Header (Image, Name, Specialty)
                Image("99")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                
                Text(medicalInstitution.hospitalName)
                    .font(.headline)
                Text(medicalInstitution.doctorName)
                    .font(.headline)
                Text(medicalInstitution.specialty)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !medicalInstitution.phoneNumber.isEmpty {
                    Divider()
                        .frame(width: 200, height: 10)
                    
                    HStack {
                        
                        Image(systemName: "phone.connection.fill")
                        
                        Link(destination: URL(string: "tel:\(medicalInstitution.phoneNumber)")!) {
                            Text(medicalInstitution.phoneNumber)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal)
            .overlay(
                            // ✏️ 右上に小さな編集ボタンを配置
                            Button(action: {
                                showEditSheet = true
                            }) {
                                Image(systemName: "pencil.circle.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.gray)
                                    .background(Circle().fill(Color.white)) // 背景を白にして視認性UP
                            }
                            .offset(x: -25, y: 10), // 右上に配置
                            alignment: .topTrailing
                        )
            
            VStack {
                Image("88")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                
                Text("次回の診療予約")
                    .font(.headline)

                // 予約リストの表示
                if appointments.isEmpty {
                    Text("今後の予定はまだありません")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List(appointments) { appointment in
                        HStack {
                            // チェックボックス
                            Button(action: {
                                // チェックボックスがタップされたとき、完了リストに追加
                                if let index = completedAppointments.firstIndex(of: appointment) {
                                    completedAppointments.remove(at: index) // 完了予定をリストから削除
                                } else {
                                    completedAppointments.append(appointment) // 完了予定をリストに追加
                                }
                                // 保存して変更を反映
                                do {
                                    try modelContext.save()
                                } catch {
                                    print("保存エラー: \(error)")
                                }
                            }) {
                                Image(systemName: completedAppointments.contains(appointment) ? "checkmark.circle.fill" : "checkmark.circle")
                                    .foregroundColor(.green)
                            }
                            .buttonStyle(PlainButtonStyle()) // ボタンのデフォルトスタイルを無効化
                            
                            // 予約情報
                            Text(dateFormatter.string(from: appointment.date)) // 日付
                                .foregroundColor(.primary)
                            Spacer()
                            Text(appointment.date, format: .dateTime.hour().minute()) // 時間
                                .foregroundColor(.primary)
                        }
                        .onTapGesture {
                            // 予約タップ時にselectedAppointmentに設定してシートを表示
                            selectedAppointment = appointment
                            showAddAppointmentSheet = true
                        }
                        .swipeActions {
                            Button("削除") {
                                // 削除確認ダイアログを表示
                                appointmentToDelete = appointment
                                showDeleteAlert = true
                            }
                            .tint(.red)
                        }
                    }
                    .listStyle(PlainListStyle())
                }

                Button("診療予約を追加") {
                    selectedAppointment = nil // 新規予約追加用に選択を解除
                    showAddAppointmentSheet = true
                }
                .padding(.top, 10)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color("LightPurple"))
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                .padding(.horizontal)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal)
            
            // 完了した予定ボタン
            Button("完了した予定") {
                showCompletedScheduleSheet.toggle() // ボタンをタップした時にSheetを表示
            }
            .foregroundColor(.gray)
            .padding(.top, 10)
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color("GoogleBackground"))
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal)
        }
        .padding()
        .sheet(isPresented: $showAddAppointmentSheet) {
            AddAppointmentView(
                medicalInstitution: medicalInstitution,
                appointment: selectedAppointment
            )
        }
        .sheet(isPresented: $showCompletedScheduleSheet) {
            CompletedScheduleView(completedAppointments: completedAppointments) // 完了した予定のSheetを表示
        }
        .sheet(isPresented: $showEditSheet) {
                    EditMedicalInstitutionView(medicalInstitution: medicalInstitution)
                }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("削除の確認"),
                message: Text("本当に削除しますか？"),
                primaryButton: .destructive(Text("削除")) {
                    if let appointmentToDelete = appointmentToDelete {
                        // SwiftDataのContextから削除
                        modelContext.delete(appointmentToDelete)  // modelContextを使用して削除
                        do {
                            try modelContext.save()  // 保存して変更を反映
                        } catch {
                            print("削除エラー: \(error)")
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

