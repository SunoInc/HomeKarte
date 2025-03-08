//
//  MedicineView.swift
//  Home Karte
//
//  Created by Shota Sunohara on 2025/02/08.
//


import SwiftUI
import SwiftData

struct MedicineView: View {
    @Query(sort: \Medicine.name) private var medicines: [Medicine]
    @Environment(\.modelContext) private var context
    @State private var newMedicineName: String = ""
    @State private var isShowingSheet = false
    @State private var isPressed = false
    @State private var searchText = ""
    @State private var selectedMedicine: Medicine?
    @State private var selectedMedicineForSheet: Medicine?
    @State private var selectedMedicineForDelete: Medicine?
    @State private var isShowingDeleteAlert = false
    @State private var isShowingDetailView = false

    var filteredMedicines: [Medicine] {
        let sortedMedicines = medicines.sorted {
            if $0.isTaking != $1.isTaking {
                return $0.isTaking && !$1.isTaking
            }
            return $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
        
        if searchText.isEmpty {
            return sortedMedicines
        } else {
            return sortedMedicines.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                VStack {
                    if searchText.isEmpty {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("GoogleLightBlue"), lineWidth: 3)
                            .foregroundColor(.clear)
                            .frame(width: 360, height: 80)
                            .overlay(
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Image(systemName: "cross.vial")
                                        Text("薬の詳細と効用を記録できるよ")
                                            .font(.body)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    HStack {
                                        Image(systemName: "bell.and.waves.left.and.right.fill")
                                        Text("お薬のリマインドもできるよ")
                                            .font(.body)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                    .foregroundColor(.black)
                                    .padding()
                            )
                            .padding(.bottom, 30)
                    }

                    List {
                        ForEach(filteredMedicines) { medicine in
                            NavigationLink(destination: MedicineDetailView(medicine: medicine)) {
                                HStack {
                                                Text(medicine.name)
                                                Spacer()
                                    HStack {
                                                        if medicine.isTaking {
                                                            Text("服用中")
                                                                .font(.caption)
                                                                .padding(6)
                                                                .background(Color.green.opacity(0.2))
                                                                .cornerRadius(8)
                                                        }
                                                        if medicine.isReminderOn {
                                                            Text("🔔")
                                                                .font(.caption)
                                                                .padding(6)
                                                                .cornerRadius(8)
                                                        }
                                                    }
                                            }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    selectedMedicineForDelete = medicine
                                    isShowingDeleteAlert = true
                                } label: {
                                    Label("削除", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                .searchable(text: $searchText, prompt: "お薬の名前を検索")
                .navigationTitle("💊お薬一覧")
                .overlay {
                    if medicines.isEmpty {
                        ContentUnavailableView(
                            label: {
                                Label {
                                    Text("まだ薬が登録されていません")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                } icon: {
                                    Image(systemName: "pills.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                            }
                        )
                    }
                }
                .alert("本当に削除して大丈夫？👀", isPresented: $isShowingDeleteAlert, presenting: selectedMedicineForDelete) { medicine in
                    Button("キャンセル", role: .cancel) {}
                    Button("削除", role: .destructive) {
                        deleteMedicine(medicine)
                    }
                } message: { medicine in
                    Text("\(medicine.name) を削除しますか？")
                }

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
                        isShowingSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.title3.weight(.semibold))
                                .foregroundColor(Color.blue)

                            Text("新しい薬")
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
        }
        .sheet(isPresented: $isShowingSheet) {
            VStack {
                Image(systemName: "pills.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                
                Text("新しい薬を追加")
                    .font(.headline)
                    .padding()

                TextField("薬の名前を入力", text: $newMedicineName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                HStack {
                    Spacer()
                    Button {
                        addMedicine()
                    } label: {
                        Label {
                            Text("保存").bold()
                        } icon: {
                            Image(systemName: "pawprint.fill")
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(newMedicineName.isEmpty)
                    .padding()
                }
            }
            .padding()
            .presentationDetents([.fraction(0.5), .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedMedicine) { medicine in
            MedicineDetailView(medicine: medicine)
        }
    }

    private func addMedicine() {
        let newMedicine = Medicine(name: newMedicineName)
        context.insert(newMedicine)
        do {
            try context.save()
            selectedMedicine = newMedicine
            isShowingSheet = false
        } catch {
            print("エラー: \(error)")
        }
        newMedicineName = ""
    }

    private func deleteMedicine(_ medicine: Medicine) {
        context.delete(medicine)
        do {
            try context.save()
        } catch {
            print("削除エラー: \(error)")
        }
    }
}

#Preview {
    MedicineView()
}
