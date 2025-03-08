//
//  LogDetailView.swift
//  Home Karte
//
//  Created by Shota Sunohara on 2025/02/08.
//

import SwiftUI
import PhotosUI

@MainActor
final class PhotoPickerViewModel: ObservableObject {
    @Published var selectedImages: [UIImage] = []
    @Published var imageSelections: [PhotosPickerItem] = [] {
        didSet {
            setImages(from: imageSelections)
        }
    }
    
    private var log: Log
        
        init(log: Log) {
            self.log = log
        }
    
    private func setImages(from selections: [PhotosPickerItem]) {
        print("setImagesが呼ばれました！ 選択数: \(selections.count)")
        
        Task {
            var images: [UIImage] = []
            var base64Strings: [String] = []
            for selection in selections {
                            if let data = try? await selection.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data),
                               let base64 = uiImage.toBase64String() {
                                images.append(uiImage)
                                base64Strings.append(base64)
                            }
                        }
            DispatchQueue.main.async {
                        self.selectedImages = images
                        self.log.imageStrings = base64Strings
                        self.objectWillChange.send()
                    }
            
                        print("画像選択後の imageStrings: \(log.imageStrings)")
                    }
                }
            }

struct LogDetailView: View {
    
    @Bindable var log: Log
    @State private var textEditorHeight: CGFloat = 100
    @State private var isPressed = false
    @State private var isExpenseExpanded = false
    @State private var selectedImage: UIImage?
    @State private var isImageFullScreen = false
    @State private var isShowingDatePicker = false
        private var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年M月d日"
            return formatter
        }
    @Environment(\.modelContext) var context
    @StateObject private var viewModel: PhotoPickerViewModel
    
    var onSave: (() -> Void)?
    var onCancel: (() -> Void)?
    
    init(log: Log, onSave: (() -> Void)? = nil, onCancel: (() -> Void)? = nil) {
            self.log = log
            self.onSave = onSave
            self.onCancel = onCancel
            _viewModel = StateObject(wrappedValue: PhotoPickerViewModel(log: log))
        }
    
    var body: some View {
        NavigationStack {
                Form {
                    Section(header: Text("🗓️日付")) {
                        Button {
                            isShowingDatePicker = true
                        } label: {
                            Text(dateFormatter.string(from: log.date))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    Section(header: Text("🏥病院（記録タブに表示されます）")) {
                        TextField("病院名", text: $log.hospital)
                    }
                    
                    Section(header: Text("🤒症状（記録タブに表示されます）")) {
                        TextEditor(text: $log.status)
                            .frame(minHeight: 50)
                    }
                    
                    DisclosureGroup("💰費用の詳細を記録する", isExpanded: $isExpenseExpanded) {
                        Section(header: Text("医療費")) {
                            HStack {
                                Text("💰支払った金額")
                                    .frame(width: 120, alignment: .leading)
                                TextField("", text: $log.medicalExpense)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(maxWidth: .infinity)
                                Text("円")
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Text("💰保険金額")
                                    .frame(width: 120, alignment: .leading)
                                TextField("高額医療費等", text: $log.insuranceCoverage)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(maxWidth: .infinity)
                                Text("円")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Section(header: Text("交通費（一般的な支出額であれば医療費控除対象🤔）")) {
                            HStack {
                                Text("💰交通費")
                                    .frame(width: 120, alignment: .leading)
                                TextField("", text: $log.transportationCost)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(maxWidth: .infinity)
                                Text("円")
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Text("🚗交通手段")
                                    .frame(width: 120, alignment: .leading)
                                TextField("", text: $log.transportationMethod)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(maxWidth: .infinity)
                            }
                            
                            HStack {
                                Text("🗺️ルート")
                                    .frame(width: 120, alignment: .leading)
                                TextField("", text: $log.route)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    
                    Section(header: Text("📓備考（検査内容や今後の方針等々）")) {
                        TextEditor(text: $log.note)
                            .frame(minHeight: 50)
                    }
                    
                    Section(header: Text("📷画像")) {
                        if !viewModel.selectedImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(viewModel.selectedImages, id: \ .self) { image in
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(8)
                                            .onTapGesture {
                                                selectedImage = image
                                                isImageFullScreen = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $viewModel.imageSelections, matching: .images) {
                            Image(systemName: "photo.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.black)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .onAppear {
                    viewModel.selectedImages = log.imageStrings.compactMap { UIImage.fromBase64String($0) }
                }
                .onChange(of: log.imageStrings) { newStrings in
                    viewModel.selectedImages = newStrings.compactMap { UIImage.fromBase64String($0) }
                }
                .overlay(
                    Group {
                        if isShowingDatePicker {
                            ZStack {
                                Color.white.opacity(0.3)
                                    .edgesIgnoringSafeArea(.all)
                                    .onTapGesture {
                                        isShowingDatePicker = false
                                    }

                                VStack {
                                    DatePicker(
                                        "日付を選択",
                                        selection: $log.date,
                                        displayedComponents: [.date]
                                    )
                                    .datePickerStyle(.graphical)

                                    Button("決定") {
                                        isShowingDatePicker = false
                                    }
                                    .padding()
                                }
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(radius: 10)
                            }
                        }
                    }
                )
                .overlay(
                    Group {
                        if isImageFullScreen, let selectedImage = selectedImage {
                            Color.black.opacity(0.7)
                                .edgesIgnoringSafeArea(.all)

                            ZStack {
                                Button(action: {
                                    isImageFullScreen = false
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.white)
                                        .padding(10)
                                }
                                .position(x: 30, y: 30)
                                
                                VStack {
                                    Spacer()
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    Spacer()
                                }
                                .background(Color.clear)
                                .cornerRadius(12)
                                .shadow(radius: 20)
                            }
                        }
                    }
                )

                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            onCancel?()
                        } label: {
                            Label {
                                Text("キャンセル")
                            } icon: {
                                Image(systemName: "clear.fill")
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                                isPressed.toggle()
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                                    isPressed = false
                                }
                            }
                            
                            context.insert(log)
                            
                            onSave?()
                            
                        } label: {
                            Label {
                                Text("保存").bold()
                            } icon: {
                                Image(systemName: "pawprint.fill")
                            }
                        }
                        .labelStyle(.titleAndIcon)
                        .buttonStyle(.bordered)
                        .scaleEffect(isPressed ? 1.1 : 1.0)
                        .disabled(log.hospital.isBlank || log.status.isBlank)
                }
            }
        }
    }
}

#Preview {
    LogDetailView(log: Log(hospital: "", status: "", note: "", date: Date()))
}
