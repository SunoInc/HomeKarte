//
//  TimelineView.swift
//  Home Karte
//
//  Created by Shota Sunohara on 2025/03/05.
//

import SwiftUI
import SwiftData

struct TimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showMenu = false
    @State private var showAddMedicalInstitution = false
    @State private var showDeleteConfirmation = false
    @State private var itemToDelete: MedicalInstitution?
    
    @Query private var medicalInstitutions: [MedicalInstitution]
    @Query private var appointments: [Appointment]
    
    var sortedMedicalInstitutions: [MedicalInstitution] {
        medicalInstitutions.sorted { a, b in
            let earliestA = appointments
                .filter { $0.medicalInstitutionID == a.id }
                .map { $0.date }
                .min() ?? Date.distantFuture
            
            let earliestB = appointments
                .filter { $0.medicalInstitutionID == b.id }
                .map { $0.date }
                .min() ?? Date.distantFuture
            
            return earliestA < earliestB
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack {
                        ForEach(sortedMedicalInstitutions, id: \.id) { medicalInstitution in
                            TimelineRowView(medicalInstitution: medicalInstitution)
                                .contextMenu {
                                                                Button(role: .destructive) {
                                                                    showDeleteConfirmation = true
                                                                    itemToDelete = medicalInstitution
                                                                } label: {
                                                                    Label("削除", systemImage: "trash")
                                                                }
                                                            }
                        }
                    }
                }
                .alert(isPresented: $showDeleteConfirmation) {
                                Alert(
                                    title: Text("削除確認"),
                                    message: Text("\(itemToDelete?.hospitalName ?? "") を削除しますか？\n（診療予約データも削除されます）"),
                                    primaryButton: .destructive(Text("削除"), action: {
                                        if let item = itemToDelete {
                                            deleteMedicalInstitution(item)
                                        }
                                    }),
                                    secondaryButton: .cancel()
                                )
                            }
                
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        if showMenu {
                            Button(action: {
                                showAddMedicalInstitution = true
                            }) {
                                menuButtonLabel(text: "医療機関・医師を追加", systemImage: "plus")
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .offset(y: showMenu ? -10 : 0)
                            .opacity(showMenu ? 1 : 0)
                                                        
                            Button(action: {
                                print("メニュー2がタップされました")
                            }) {
                                menuButtonLabel(text: "予定を追加", systemImage: "plus")
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .offset(y: showMenu ? -5 : 0)
                            .opacity(showMenu ? 1 : 0)
                        }
                        
                        Button {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                showMenu.toggle()
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus")
                                    .font(.title3.weight(.semibold))
                                    .foregroundColor(Color.blue)
                                
                                Text("新しい予定")
                                    .font(.body)
                                    .foregroundColor(Color.blue)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(Color("GoogleLightBlue"))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding()
                .offset(y: 220)
            }
            .navigationTitle("サポート")
            .sheet(isPresented: $showAddMedicalInstitution) {
                AddMedicalInstitutionView(medicalInstitution: MedicalInstitution(hospitalName: "", doctorName: "", specialty: "", phoneNumber: "", email: "", postalCode: "", prefecture: "", city: "", address: ""))
            }
        }
    }
    
    func deleteMedicalInstitution(_ medicalInstitution: MedicalInstitution) {
            modelContext.delete(medicalInstitution)
            try? modelContext.save()
        }
    
    private func menuButtonLabel(text: String, systemImage: String) -> some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.white)
            
            Text(text)
                .font(.body)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.blue)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
    }
}

//#Preview {
//    TimelineView()
//}
