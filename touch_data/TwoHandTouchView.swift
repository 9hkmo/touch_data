//
//  TwoHandTouchView.swift
//  touch_data
//
//  Created by 구혁모 on 7/9/25.
//

import SwiftUI

struct TargetCircle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var createdTime: Date = Date()
}

struct TwoHandTouchView: View {
    @State private var leftTargets: [TargetCircle] = []
    @State private var rightTargets: [TargetCircle] = []
    
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect() // ✅ 2초마다

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                // 왼쪽 원
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: geo.size.height, height: geo.size.height)

                    ForEach(leftTargets) { target in
                        Circle()
                            .fill(Color.red)
                            .frame(width: 40, height: 40)
                            .position(target.position)
                            .onTapGesture {
                                let center = CGPoint(x: geo.size.height / 2, y: geo.size.height / 2)
                                logTouch(target: target, isLeft: true, center: center)
                                leftTargets.removeAll { $0.id == target.id }
                            }
                    }
                }
                .frame(width: geo.size.width / 2, height: geo.size.height)

                // 오른쪽 원
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: geo.size.height, height: geo.size.height)

                    ForEach(rightTargets) { target in
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 40, height: 40)
                            .position(target.position)
                            .onTapGesture {
                                let center = CGPoint(x: geo.size.height / 2, y: geo.size.height / 2)
                                logTouch(target: target, isLeft: false, center: center)
                                rightTargets.removeAll { $0.id == target.id }
                            }

                    }
                }
                .frame(width: geo.size.width / 2, height: geo.size.height)
            }
//            .overlay(
//                Text("📱 화면을 왼쪽으로 돌려 가로모드로 사용해 주세요.\n🖐 왼손으로 왼쪽, 오른손으로 오른쪽을 조작하세요.")
//                    .font(.headline)
//                    .multilineTextAlignment(.center)
//                    .padding()
//                    .background(Color.white.opacity(0.8))
//                    .cornerRadius(12)
//                    .padding(),
//                alignment: .top
//            )
            .onReceive(timer) { _ in
                let size = geo.size.height
                addRandomTarget(to: &leftTargets, in: size)
                addRandomTarget(to: &rightTargets, in: size)
            }
        }
        .ignoresSafeArea()
    }

    func logTouch(target: TargetCircle, isLeft: Bool, center: CGPoint) {
        let now = Date()
        let duration = now.timeIntervalSince(target.createdTime)
        
        let dx = target.position.x - center.x
        let dy = target.position.y - center.y
        let distance = sqrt(dx * dx + dy * dy)
        
        print("""
        🖐 \(isLeft ? "왼쪽" : "오른쪽") 터치!
        ⤷ 중심 기준 상대 위치: (dx: \(String(format: "%.2f", dx)), dy: \(String(format: "%.2f", dy)))
        ⤷ 중심과의 거리: \(String(format: "%.2f", distance))pt
        ⤷ 반응속도: \(String(format: "%.2f", duration))s
        """)
    }


    func addRandomTarget(to array: inout [TargetCircle], in size: CGFloat) {
        if array.count >= 10 { return } // 최대 10개까지만 허용
        let radius = size / 2
        let angle = Double.random(in: 0..<2 * .pi)
        let r = Double.random(in: 40...(radius - 40))
        let x = CGFloat(radius + cos(angle) * r)
        let y = CGFloat(radius + sin(angle) * r)
        array.append(TargetCircle(position: CGPoint(x: x, y: y)))
    }
}

#Preview {
    TwoHandTouchView()
}
