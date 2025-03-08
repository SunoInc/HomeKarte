//
//  LogView.swift
//  Home Karte
//
//  Created by Shota Sunohara on 2025/02/08.
//

import SwiftUI
import SwiftData

struct LogView: View {
    
    @State private var isPressed = false
    @State private var isShowingSheet = false
    @State private var logs = Log.emptyList
    @State private var selectedLog: Log? = nil
    @Environment(\.modelContext) var context
    @State private var showDeleteAlert = false
    @State private var logToDelete: Log?
    @State private var isSettingPresented = false
    
    @Query var swiftDataLogs: [Log]
    
    var body: some View {
            NavigationStack {
                ZStack(alignment: .bottom) {
                    ScrollView {
                        VStack {
                                Image("HomeKarte_1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 201, height: 59)
                                    .padding(.bottom, 20)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            
                            if !swiftDataLogs.isEmpty {
                                Text("通院の記録")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom, 5)
                            }
                            
                            ForEach(swiftDataLogs.sorted(by: { $0.date > $1.date })) { log in
                                LogRowView(log: log)
                                    .onTapGesture {
                                        selectedLog = log
                                        isShowingSheet = true
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            logToDelete = log
                                            showDeleteAlert = true
                                        } label: {
                                            Label("削除", systemImage: "trash")
                                        }
                                    }
                                    .alert("この記録を削除しますか？", isPresented: $showDeleteAlert) {
                                        Button("キャンセル", role: .cancel) {}
                                        Button("削除", role: .destructive) {
                                            if let log = logToDelete {
                                                context.delete(log)
                                                logToDelete = nil
                                            }
                                        }
                                    } message: {
                                        Text("削除したデータは元に戻せません🤔")
                                    }
                            }
                            
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .overlay {
//                        if swiftDataLogs.isEmpty {
//                            ContentUnavailableView(
//                                label: {
//                                    Label {
//                                    } icon: {
//                                        Image("dogicon")
//                                            .resizable()
//                                            .scaledToFit()
//                                            .frame(width: 250, height: 250)
//                                    }
//                                }
//                            )
//                        }
//                    }
                    
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                                isPressed = true
                            }
                            
                            Task {
                                    try? await Task.sleep(nanoseconds: 100_000_000)
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                                        isPressed = false
                                    }
                                }
                            
                            selectedLog = nil
                            isShowingSheet = true
                            
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.title3.weight(.semibold))
                                    .foregroundColor(Color.blue)
                                
                                Text("新しい記録")
                                    .font(.body)
                                    .foregroundColor(Color.blue)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color("GoogleLightBlue"))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .scaleEffect(isPressed ? 1.1 : 1.0)
                    }
                    .padding()
                    .offset(y: -50)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.white, for: .navigationBar)
                .toolbarColorScheme(.light, for: .navigationBar)
                .shadow(color: .clear, radius: 0)
                .navigationBarItems(trailing:
                    Button(action: {
                         isSettingPresented = true
                    }) {
                        Image(systemName: "suit.heart.fill")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                )
                .sheet(isPresented: $isSettingPresented) {
                                SettingView()
                            }
                .sheet(isPresented: $isShowingSheet) {
                                if let log = selectedLog {
                                    LogDetailView(log: log,
                                                  onSave: { isShowingSheet = false },
                                                  onCancel: { isShowingSheet = false }
                                    )
                                        .presentationDetents([.large])
                                        .presentationDragIndicator(.hidden)
                                } else {
                                    LogDetailView(log: Log(hospital: "", status: "", note: "", date: Date()),
                                                  onSave: { isShowingSheet = false },
                                                  onCancel: { isShowingSheet = false }
                                    )
                                        .presentationDetents([.large])
                                        .presentationDragIndicator(.hidden)
                                }
                            }
                        }
                    }
                }



//#Preview {
//    LogView()
//}
