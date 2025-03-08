//
//  MedicineDetailView.swift
//  Home Karte
//
//  Created by Shota Sunohara on 2025/02/15.
//

import SwiftUI
import SwiftData

enum Weekday: Int, CaseIterable, Identifiable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    var id: Int { self.rawValue }
    
    var shortName: String {
        switch self {
        case .sunday: return "日"
        case .monday: return "月"
        case .tuesday: return "火"
        case .wednesday: return "水"
        case .thursday: return "木"
        case .friday: return "金"
        case .saturday: return "土"
        }
    }
}

struct MedicineDetailView: View {
    @Bindable var medicine: Medicine
    @State private var isPickerPresented = false
    @State private var selectedCategory = "一般"
    @State private var isScheduleExpanded = false
    @State private var isTypeExpanded = false
    @State private var showAlert = false
    
    let categories: [String: [String]] = [
        "一般": ["カプセル", "錠剤", "液体", "外用薬"],
        "その他": ["クリーム", "ゲル", "スプレー", "デバイス", "パッチ", "フォーム", "ローション", "吸入器", "座薬", "注射", "滴剤", "粉薬", "軟膏"]
    ]
    
    let units: [String] = ["mg", "μg", "g", "mL", "%"]
//    let scheduleOptions = ["毎日", "特定の曜日", "数日おき", "周期的なスケジュール", "必要なとき"]
//    let weekdays = ["日", "月", "火", "水", "木", "金", "土"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("薬の名前")) {
                    TextField("薬の名前を入力", text: $medicine.name)
                }
                
                Section(header: Text("🔔リマインダーの設定")) {
                    Toggle(isOn: $medicine.isReminderOn) {
                        Text(medicine.isReminderOn ? "設定している時間で通知されます" : "通知されません")
                            .foregroundColor(.secondary)
                    }
                    .onChange(of: medicine.isReminderOn) { newValue in
                        if newValue {
                            checkNotificationAuthorization()
//                            NotificationManager.shared.scheduleNotifications(for: medicine)
                        } else {
                            NotificationManager.shared.cancelNotifications(for: medicine)
                        }
                    }
                }
                .alert("通知が許可されていません", isPresented: $showAlert) {
                            Button("設定を開く") {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            Button("キャンセル", role: .cancel) { }
                        } message: {
                            Text("通知が許可されていません。設定アプリで通知を有効にしてください。")
                        }
                
                DisclosureGroup("🗓️服用スケジュールを設定する", isExpanded: $isTypeExpanded) {
                    Section(header: Text("服用の状況")) {
                        Toggle(isOn: $medicine.isTaking) {
                            Text(medicine.isTaking ? "服用中に表示" : "その他の薬一覧に表示")
//                                .foregroundColor(.secondary)
                        }
                    }
                    Section(header: Text("いつ服用しますか？")) {
                                        Picker("服用スケジュール", selection: $medicine.scheduleType) {
                                            ForEach(ScheduleType.allCases, id: \.self) { option in
                                                Text(option.rawValue).tag(option)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                    }

                    if medicine.scheduleType == .specificDays {
                        Section(header: Text("服用する曜日")) {
                            HStack {
                                ForEach(Weekday.allCases) { day in
                                    Button(action: {
                                        if let index = medicine.selectedDays.firstIndex(of: day.rawValue) {
                                            // 既に選択されている場合は削除
                                            medicine.selectedDays.remove(at: index)
                                        } else {
                                            // 選択されていない場合は追加
                                            medicine.selectedDays.append(day.rawValue)
                                        }
                                    }) {
                                        Text(day.shortName)
                                            .font(.headline)
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(medicine.selectedDays.contains(day.rawValue) ? .white : .blue)
                                            .background(medicine.selectedDays.contains(day.rawValue) ? Color.blue : Color.clear)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.blue, lineWidth: 1)
                                            )
                                    }
                                    .contentShape(Rectangle()) // タップしやすくする
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }


                    if medicine.scheduleType == .interval {
                                        Section(header: Text("何日おきに服用しますか？")) {
                                            Stepper("\(medicine.intervalDays)日おき", value: $medicine.intervalDays, in: 1...99)
                                        }
                                    }

                                    if medicine.scheduleType == .periodic {
                                        Section(header: Text("服薬期間")) {
                                            Stepper("\(medicine.medicationPeriod)日間服用", value: $medicine.medicationPeriod, in: 1...99)
                                        }
                                        Section(header: Text("休薬期間")) {
                                            Stepper("\(medicine.restPeriod)日間休薬", value: $medicine.restPeriod, in: 1...99)
                                        }
                                    }

                    if medicine.scheduleType != .asNeeded {
                        Section(header: Text("何時に服用しますか？")) {
                            List {
                                ForEach(medicine.selectedTimes, id: \.self) { time in
                                    DatePicker(
                                        "服用時間",
                                        selection: Binding(
                                            get: { time },
                                            set: { newTime in
                                                if let index = medicine.selectedTimes.firstIndex(of: time) {
                                                    medicine.selectedTimes[index] = newTime
                                                    NotificationManager.shared.scheduleNotifications(for: medicine)
                                                }
                                            }
                                        ),
                                        displayedComponents: .hourAndMinute
                                    )
                                }
                                .onDelete { indices in
                                    medicine.selectedTimes.remove(atOffsets: indices) // 安全な削除
                                    NotificationManager.shared.scheduleNotifications(for: medicine)
                                }
                            }
                            Button(action: {
                                medicine.selectedTimes.append(Date())
                                NotificationManager.shared.scheduleNotifications(for: medicine)
                            }) {
                                Label("時間を追加", systemImage: "plus.circle.fill")
                            }
                        }
                    }

                                    Section(header: Text("服用期間")) {
                                        DatePicker("開始日", selection: $medicine.startDate, displayedComponents: .date)

                                        if medicine.endDate == nil {
                                            Button("終了日を設定") {
                                                medicine.endDate = Date()
                                            }
                                            .buttonStyle(.borderedProminent)
                                        } else {
                                            DatePicker("終了日", selection: Binding(
                                                get: { medicine.endDate ?? Date() },
                                                set: { medicine.endDate = $0 }
                                            ), displayedComponents: .date)
                                            Button("終了日なし") {
                                                medicine.endDate = nil
                                            }
                                            .buttonStyle(.borderedProminent)
                                        }
                                    }
                }
                
                DisclosureGroup("💊薬の種類を記録する", isExpanded: $isScheduleExpanded) {
                    Section(header: Text("薬の種類")) {
                                        Button(action: {
                                            isPickerPresented.toggle()
                                        }) {
                                            HStack {
                                                Text("種類を選択")
                                                Spacer()
                                                Text(medicine.type)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .sheet(isPresented: $isPickerPresented) {
                                            MedicineTypePicker(
                                                selectedCategory: $selectedCategory,
                                                selectedType: $medicine.type,
                                                categories: categories
                                            )
                                        }
                                    }
                    
                    Section(header: Text("有効成分量")) {
                        HStack {
                            TextField("量を入力", text: $medicine.activeIngredientAmount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 100)
                            
                            Picker("単位", selection: $medicine.unit) {
                                ForEach(units, id: \ .self) { unit in
                                    Text(unit).tag(unit)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                }
                
                Section(header: Text("副作用・効用の記録")) {
                    TextEditor(text: $medicine.sideEffects)
                        .frame(minHeight: 100)
                }
                
            }
            .navigationTitle("📃お薬の詳細")
        }
    }
    
    private func checkNotificationAuthorization() {
            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings { settings in
                DispatchQueue.main.async {
                    switch settings.authorizationStatus {
                    case .authorized, .provisional:
                        // 通知が許可されているのでスケジュールする
                        NotificationManager.shared.scheduleNotifications(for: medicine)
//                    case .notDetermined:
//                        // まだ許可が決まっていないのでリクエスト
//                        requestNotificationPermission()
                    case .denied:
                        DispatchQueue.main.async {
                            showAlert = true
                            medicine.isReminderOn = false
                                        }
                    default:
                        break
                    }
                }
            }
        }

        private func requestNotificationPermission() {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        NotificationManager.shared.scheduleNotifications(for: medicine)
                    } else {
                        showAlert = true
                        medicine.isReminderOn = false // UIの状態を元に戻す
                    }
                }
            }
        }
    
}



struct MedicineTypePicker: View {
    @Binding var selectedCategory: String
    @Binding var selectedType: String
    let categories: [String: [String]]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("カテゴリー", selection: $selectedCategory) {
                    ForEach(categories.keys.sorted(), id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Picker("種類", selection: $selectedType) {
                    ForEach(categories[selectedCategory] ?? [], id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                
                Button("完了") {
                    dismiss()
                }
                .padding()
            }
            .navigationTitle("薬の種類を選択")
        }
    }
}
