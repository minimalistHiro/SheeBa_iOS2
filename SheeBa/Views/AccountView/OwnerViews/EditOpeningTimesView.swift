//
//  EditOpeningTimesView.swift
//  SheeBa
//
//  Created by 金子広樹 on 2025/02/14.
//

import SwiftUI

struct EditOpeningTimesView: View {
    
    @State private var mondayStart: Date = Date()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    Text("日曜日")
                        .foregroundStyle(Color.black)
                        .opacity(0.5)
                        .font(.callout)
                        .padding(.trailing, 30)
                    
                    Spacer()
                    
                    DatePicker("時間", selection: $mondayStart, displayedComponents: .hourAndMinute)
                                    .environment(\.locale, Locale(identifier: "ja_JP"))
                                    .padding(.horizontal, 100)// 水平方向のpaddingを調整
                                    .padding(.bottom, 20)
                }
                .padding()
            }
        }
    }
}

#Preview {
    EditOpeningTimesView()
}
