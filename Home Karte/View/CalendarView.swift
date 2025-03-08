//
//  HospitalView.swift
//  Home Karte
//
//  Created by Shota Sunohara on 2025/02/17.
//

//import SwiftUI
//
//struct CalendarView: View {
//    
//    @State private var currentDate = Date()
//    @State private var isPressed = false
//    @State private var isShowingSheet = false
//    @State private var title: String = ""
//    @State private var selectedDate: Date = Date() // 選択された日付（デフォルトは今日）
//    @State private var events: [Date: [String]] = [:]
//    
//    
//    private let calendar = Calendar.current
//
//    private var currentYear: String {
//        String(calendar.component(.year, from: currentDate))
//    }
//
//    private var currentMonth: String {
//        String(calendar.component(.month, from: currentDate))
//    }
//
//    private var daysInMonth: Int {
//        calendar.range(of: .day, in: .month, for: currentDate)?.count ?? 30
//    }
//
//    private var firstDayOfMonthWeekday: Int {
//        let firstDay = calendar.date(from: DateComponents(year: calendar.component(.year, from: currentDate),
//                                                          month: calendar.component(.month, from: currentDate))) ?? Date()
//        return calendar.component(.weekday, from: firstDay) - 2
//    }
//
//    private var today: Int {
//        calendar.component(.day, from: Date())
//    }
//    
//    private var formattedSelectedDate: String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy年 M月 d日"
//        return formatter.string(from: selectedDate)
//    }
//
//    var body: some View {
//        ZStack(alignment: .bottomTrailing) {
//            VStack {
//                headerView
//                weekdayHeader
//                Divider()
//                
//                dateGrid
//                
//                Divider()
//                
//                Text("\(formattedSelectedDate)")
//                    .font(.headline)
//                    .padding(.vertical, 8)
//                
//                ScrollView {
//                                List {
//                                    if let eventList = events[selectedDate] {
//                                        ForEach(eventList, id: \ .self) { event in
//                                            Text(event)
//                                        }
//                                    } else {
//                                        Text("予定はありません")
//                                            .foregroundColor(.gray)
//                                    }
//                                }
//                                .frame(height: 300) // 適度な高さ
//                            }
//            }
//            HStack {
//                Spacer()
//                Button {
//                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
//                        isPressed = true
//                    }
//                    
//                    Task {
//                        try? await Task.sleep(nanoseconds: 100_000_000)
//                        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
//                            isPressed = false
//                        }
//                    }
//                    title = "" // 新しい予定を入力できるよう初期化
//                    selectedDate = Date() // 初期値として今日の日付を設定
//                    isShowingSheet = true
//                    
//                } label: {
//                    HStack(spacing: 8) {
//                        Image(systemName: "plus")
//                            .font(.title3.weight(.semibold))
//                            .foregroundColor(Color.blue)
//                        
//                        Text("新しい予定")
//                            .font(.body)
//                            .foregroundColor(Color.blue)
//                    }
//                    .padding(.horizontal, 16)
//                    .padding(.vertical, 16)
//                    .background(Color("GoogleLightBlue"))
//                    .clipShape(RoundedRectangle(cornerRadius: 16))
//                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
//                }
//                .scaleEffect(isPressed ? 1.1 : 1.0)
//            }
//            .offset(y: -50)
//        }
//        .padding()
//        .sheet(isPresented: $isShowingSheet) {
//            Form {
//                
//                Section(header: Text("予定のタイトル")) {
//                    TextField("通院目的を入力", text: $title)
//                }
//                
//                DatePicker("開始", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
//                    .datePickerStyle(.compact)
//                
//                DatePicker("終了", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
//                    .datePickerStyle(.compact)
//
//                Button("保存") {
//                    let normalizedDate = calendar.startOfDay(for: selectedDate) // 時刻を削除して0:00に統一
//                    if events[normalizedDate] != nil {
//                                            events[normalizedDate]?.append(title) // 既存の予定がある場合は追加
//                                        } else {
//                                            events[normalizedDate] = [title] // 新規の日付の場合は配列を作成
//                                        }
//                    isShowingSheet = false
//                    
//                }
//            }
//        }
//    }
//
//    private var headerView: some View {
//        HStack {
//            Button(action: showPreviousMonth) {
//                Text("<")
//                    .buttonStyle
//            }
//            
//            Text("\(currentYear)年 \(currentMonth)月")
//                .font(.headline)
//                .padding()
//            
//            Button(action: showNextMonth) {
//                Text(">")
//                    .buttonStyle
//            }
//        }
//        .padding(0.1)
//    }
//
//    private var weekdayHeader: some View {
//        HStack {
//            ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
//                Text(day)
//                    .frame(maxWidth: .infinity)
//                    .padding(.top)
//            }
//        }
//        .font(.headline)
//    }
//
//    private var dateGrid: some View {
//        VStack(spacing: 4) {
//            ForEach(0..<6) { row in
//                HStack(spacing: 4) {
//                    ForEach(0..<7) { column in
//                        ZStack(alignment: .topLeading) {
//                            //(x)day, textColor
//                            let (day, textColor) = dayFor(row: row, column: column)
//                            Rectangle()
//                                .fill(isToday(day) ? Color("BackgroundGray") : Color("BackgroundLightGray").opacity(0.2))
//                                .frame(maxWidth: .infinity)
//                                .frame(height: 40)
//                                .cornerRadius(8)
//                                .onTapGesture {
//                                        if let selectedDay = Int(day) {
//                                            selectedDate = calendar.date(from: DateComponents(
//                                                year: calendar.component(.year, from: currentDate),
//                                                month: calendar.component(.month, from: currentDate),
//                                                day: selectedDay
//                                            )) ?? selectedDate // 取得できなかった場合は変更しない
//                                        }
//                                    }
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 8)
//                                        .stroke(Color("StrokeLightGray"), lineWidth: 2)
//                                )
//                            
//                            VStack(alignment: .leading, spacing: 2) {
//                                    Text(day)
//                                        .font(.caption)
//                                        .bold(isToday(day))
//                                        .foregroundColor(textColor)
//                                        .padding(5)
//                                if let selectedDay = Int(day),
//                                   let eventDate = calendar.date(from: DateComponents(
//                                       year: calendar.component(.year, from: currentDate),
//                                       month: calendar.component(.month, from: currentDate),
//                                       day: selectedDay
//                                   )) {
//                                    let normalizedDate = calendar.startOfDay(for: eventDate)
//                                    if let eventTitles = events[normalizedDate] {
//                                        VStack(alignment: .leading, spacing: 2) {
//                                            ForEach(eventTitles.prefix(2), id: \.self) { title in
//                                                Text(title)
//                                                    .font(.caption)
//                                                    .lineLimit(1)
//                                                    .truncationMode(.tail) // 長い文字は "..." に省略
//                                                    .frame(maxWidth: .infinity, alignment: .leading) // 背景を横いっぱいにする
//                                                    .padding(.horizontal, 4)
//                                                    .background(
//                                                        Rectangle()
//                                                            .fill(Color("BackgroundLightPurple"))
//                                                            .cornerRadius(4)
//                                                    )
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    private func dayFor(row: Int, column: Int) -> (String, Color) {
//        let dayOffset = row * 7 + column
//        let currentMonthDays = daysInMonth
//        let firstWeekday = firstDayOfMonthWeekday
//        
//        if dayOffset < firstWeekday { // 前月の処理
//            let prevMonthDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
//            let prevMonthDays = calendar.range(of: .day, in: .month, for: prevMonthDate)!.count
//            let prevMonthDay = prevMonthDays - (firstWeekday - dayOffset - 1)
//            return ("\(prevMonthDay)", .gray) // グレー表示
//        } else if dayOffset - firstWeekday < currentMonthDays { // 当月の日付
//            let day = dayOffset - firstWeekday + 1
//            return ("\(day)", .primary)
//        } else { // 次月の処理
//            let nextMonthDay = dayOffset - firstWeekday - currentMonthDays + 1
//            return ("\(nextMonthDay)", .gray) // グレー表示
//        }
//    }
//
//    private func isEmpty(_ row: Int, column: Int) -> Bool {
//        let day = row * 7 + column - firstDayOfMonthWeekday
//        return day <= 0 || day > daysInMonth
//    }
//
//    private func isToday(_ day: String) -> Bool {
//        guard let dayInt = Int(day),
//              calendar.isDate(Date(), equalTo: currentDate, toGranularity: .month) else {
//            return false
//        }
//        return dayInt == today
//    }
//
//    private func showPreviousMonth() {
//        if let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentDate) {
//            currentDate = previousMonth
//        }
//    }
//
//    private func showNextMonth() {
//        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentDate) {
//            currentDate = nextMonth
//        }
//    }
//}
//
//private extension Text {
//    var buttonStyle: some View {
//        self/*.padding()*/
////            .background(Color.gray.opacity(0.2))
//            .foregroundColor(.gray)
////            .cornerRadius(8)
//    }
//}
//
//struct CalendarView_Previews: PreviewProvider {
//    static var previews: some View {
//        CalendarView()
//    }
//}
