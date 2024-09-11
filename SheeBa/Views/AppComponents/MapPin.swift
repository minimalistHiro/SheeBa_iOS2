//
//  MapPin.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/04/04.
//

import SwiftUI
import SDWebImageSwiftUI

struct MapPin: View {
    let rect: CGRect                        // 図形の大きさ
    let image: String                       // トップ画像
    
    var body: some View {
        ZStack {
            triangle(in: rect)
            circle(in: rect)
                .overlay {
                    if image != "" {
                        WebImage(url: URL(string: image))
                            .resizable()
                            .scaledToFill()
                            .frame(width: rect.width / 1.8, height: rect.width / 1.8)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .stroke(.black, lineWidth: 1)
                            .frame(width: rect.width / 1.8, height: rect.width / 1.8)
                            .overlay {
                                Image(systemName: "person.fill")
                                    .font(.system(size: (rect.width / 1.8) / 2))
                                    .foregroundColor(.black)
                            }
                    }
                }
        }
    }
    // 円
    func circle(in rect: CGRect) -> some View {
        Path { path in
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                        radius: (rect.midX) / 1.5,
                        startAngle: Angle(degrees: 0),
                        endAngle: Angle(degrees: 360),
                        clockwise: true)
            path.closeSubpath()
        }
    }
    // 三角形
    func triangle(in rect: CGRect) -> some View {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.midY))      // 円中央
            path.addLine(to: CGPoint(x: rect.midX + rect.midX / 2, y: rect.midY))                                         // 右端
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))   // 下端
            path.addLine(to: CGPoint(x: rect.midX - rect.midX / 2, y: rect.midY))                                         // 左端
            path.addLine(to: CGPoint(x: rect.midX, y: rect.midY))   // 円中央
            path.closeSubpath()
        }
    }
}

//struct MapPin: Shape {
//    func path(in rect: CGRect) -> Path {
////        Path { path in
////            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
////            path.addLine(to: CGPoint(x: rect.midX / 2, y: rect.midY / 2))
////            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY / 2),
////                        radius: rect.midX,
////                        startAngle: Angle(degrees: 180),
////                        endAngle: Angle(degrees: 0),
////                        clockwise: true)
////            path.addLine(to: CGPoint(x: (rect.maxX * 3) / 4, y: rect.midY / 2))
////            path.closeSubpath()
////        }
//        
//        Path { path in
//            // 三角形
//            path.move(to: CGPoint(x: rect.midX, y: rect.midY))      // 円中央
//            path.addLine(to: CGPoint(x: rect.midX + (rect.midX) / 2, y: rect.midY))                                         // 右端
//            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))   // 先端
//            path.addLine(to: CGPoint(x: rect.midX - (rect.midX) / 2, y: rect.midY))                                         // 左端
//            path.addLine(to: CGPoint(x: rect.midX, y: rect.midY))   // 円中央
//            path.closeSubpath()
//            
//            // 円
//            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
//                        radius: (rect.midX) / 1.5,
//                        startAngle: Angle(degrees: 0),
//                        endAngle: Angle(degrees: 360),
//                        clockwise: true)
//            path.closeSubpath()
//        }
//    }
//}

#Preview {
    MapPin(rect: CGRect(x: 0, y: 0, width: 50, height: 50), image: "")
}
