//
//  FitnessView.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/10/04.
//

import SwiftUI

struct FitnessView: View {
    var body: some View {
        VStack {
            Image("Greeting")
                .resizable()
                .scaledToFill()
                .frame(width: 180, height: 180)
            Text("次の開発までお楽しみに。")
        }
    }
}

#Preview {
    FitnessView()
}
