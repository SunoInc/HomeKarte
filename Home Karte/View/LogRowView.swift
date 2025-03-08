//
//  LogRowView.swift
//  Home Karte
//
//  Created by Shota Sunohara on 2025/02/08.
//

import SwiftUI

struct LogRowView: View {
    
    let log: Log
    
    private var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年M月d日"
            return formatter
        }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .foregroundColor(.green)
                
                Text("診療日：\(dateFormatter.string(from: log.date))")
                    .font(.caption)
//                    .padding(.horizontal)
//                    .padding(.top, 5)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            .frame(maxWidth: .infinity)
            
            HStack {
                Image("77")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipped()
                
                VStack(alignment: .leading) {
                    Text(log.hospital)
                        .font(.headline)
//                        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .truncationMode(.tail)
//                        .background(
//                            RoundedRectangle(cornerRadius: 10)
//                                .fill(Color("LightPurple"))
//                        )
//                    Spacer()
                    Text(log.status)
                        .font(.subheadline)
//                        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .lineLimit(1)
                        .truncationMode(.tail)
//                        .background(
//                            RoundedRectangle(cornerRadius: 10)
//                                .fill(Color("LightPink"))
//                        )
                }
//                .frame(maxWidth: .infinity)
                
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
//        .padding(.horizontal)
    }
}

//#Preview {
//    LogRowView(log: Log(hospital: "", status: "", note: ""))
//}
