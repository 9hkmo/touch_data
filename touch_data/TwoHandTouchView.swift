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

    @State private var isRightActive = false
    @State private var isLeftActive = false

    @State private var countdownText: String? = nil
    @State private var countdownTimer: Timer? = nil

    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                // 왼쪽 원
                ZStack {
                    Circle().fill(Color.blue.opacity(0.3))
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
                    Circle().fill(Color.green.opacity(0.3))
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
            .onAppear {
                startCountdown(seconds: 3, label: "🖐 오른손 테스트 시작까지") {
                    isRightActive = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                        isRightActive = false
                        startCountdown(seconds: 3, label: "🖐 왼손 테스트 시작까지") {
                            isLeftActive = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                                isLeftActive = false
                            }
                        }
                    }
                }
            }

            .onReceive(timer) { _ in
                let size = geo.size.height
                if isRightActive {
                    addRandomTarget(to: &rightTargets, in: size)
                } else if isLeftActive {
                    addRandomTarget(to: &leftTargets, in: size)
                }
            }
            .overlay(
                Text(overlayText())
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(12)
                    .padding(),
                alignment: .top
            )
        }
        .ignoresSafeArea()
    }
    
    func overlayText() -> String {
        if let countdown = countdownText {
            return "⏳ \(countdown)"
        } else if isRightActive {
            return "🖐 오른손으로 오른쪽 원을 터치해 주세요 (30초 테스트 중)"
        } else if isLeftActive {
            return "🖐 왼손으로 왼쪽 원을 터치해 주세요 (30초 테스트 중)"
        } else {
            return "✅ 테스트 종료! 감사합니다."
        }
    }


    func logTouch(target: TargetCircle, isLeft: Bool, center: CGPoint) {
        let now = Date()
        let duration = now.timeIntervalSince(target.createdTime)
        let dx = target.position.x - center.x
        let dy = target.position.y - center.y
        let distance = sqrt(dx * dx + dy * dy)
        print("""
        🖐 \(isLeft ? "왼쪽" : "오른쪽") 터치!
        ⤷ 상대 위치: (dx: \(String(format: "%.2f", dx)), dy: \(String(format: "%.2f", dy)))
        ⤷ 거리: \(String(format: "%.2f", distance))pt, 반응속도: \(String(format: "%.2f", duration))s
        """)
    }

    func addRandomTarget(to array: inout [TargetCircle], in size: CGFloat) {
        let radius = size / 2
        let angle = Double.random(in: 0..<2 * .pi)
        let r = Double.random(in: 40...(radius - 40))
        let x = CGFloat(radius + cos(angle) * r)
        let y = CGFloat(radius + sin(angle) * r)
        array.append(TargetCircle(position: CGPoint(x: x, y: y)))
    }
    
    func startCountdown(seconds: Int, label: String, completion: @escaping () -> Void) {
        var timeLeft = seconds
        countdownText = "\(label) \(timeLeft)..."

        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            timeLeft -= 1
            if timeLeft > 0 {
                countdownText = "\(label) \(timeLeft)..."
            } else {
                timer.invalidate()
                countdownText = nil
                completion()
            }
        }
    }

}


#Preview {
    TwoHandTouchView()
}
