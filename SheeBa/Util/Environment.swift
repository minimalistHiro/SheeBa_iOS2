//
//  Environment.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/01/30.
//

import Foundation

final class Environment: ObservableObject {
    @Environment(\.openURL) var openURL
    init(){}
}
