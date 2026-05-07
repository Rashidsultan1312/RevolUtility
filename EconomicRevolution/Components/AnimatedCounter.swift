import SwiftUI

struct AnimatedCounter: View {
    let value: Double
    var prefix: String = ""
    var font: Font = .rvAmount
    var color: Color = RV.gold

    @State private var displayed: Double = 0

    var body: some View {
        Text("\(prefix)\(displayed, specifier: "%.2f")")
            .font(font)
            .foregroundStyle(color)
            .contentTransition(.numericText())
            .onAppear { displayed = value }
            .onChange(of: value) { newVal in
                withAnimation(.easeOut(duration: 0.5)) {
                    displayed = newVal
                }
            }
    }
}
