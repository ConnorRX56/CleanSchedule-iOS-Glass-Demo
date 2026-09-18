import SwiftUI

private struct SampleLesson: Identifiable {
    let id: Int
    let day: Int
    let period: Int
    let length: Int
    let title: String
    let room: String
    let tint: Color
}

struct SampleTimetable: View {
    let week: Int
    private let days = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
    private let lessons = [
        SampleLesson(id: 1, day: 0, period: 0, length: 2, title: "高等数学", room: "A201", tint: Color(red: 0.76, green: 0.87, blue: 1)),
        SampleLesson(id: 2, day: 1, period: 2, length: 2, title: "大学英语", room: "B302", tint: Color(red: 0.76, green: 0.94, blue: 0.84)),
        SampleLesson(id: 3, day: 2, period: 0, length: 2, title: "设计基础", room: "C106", tint: Color(red: 0.87, green: 0.80, blue: 1)),
        SampleLesson(id: 4, day: 3, period: 4, length: 2, title: "程序设计", room: "A405", tint: Color(red: 1, green: 0.84, blue: 0.66)),
        SampleLesson(id: 5, day: 4, period: 1, length: 2, title: "线性代数", room: "A208", tint: Color(red: 1, green: 0.79, blue: 0.87)),
        SampleLesson(id: 6, day: 1, period: 6, length: 2, title: "体育", room: "操场", tint: Color(red: 0.73, green: 0.91, blue: 0.96)),
        SampleLesson(id: 7, day: 4, period: 7, length: 2, title: "大学物理", room: "B103", tint: Color(red: 0.76, green: 0.87, blue: 1)),
    ]

    var body: some View {
        GeometryReader { proxy in
            let gutter: CGFloat = 26
            let dayWidth = (proxy.size.width - gutter) / 7
            let rowHeight = max(52, (proxy.size.height - 32) / 10)
            ZStack(alignment: .topLeading) {
                Canvas { context, size in
                    for index in 0...10 {
                        let y = 32 + CGFloat(index) * rowHeight
                        var line = Path()
                        line.move(to: CGPoint(x: gutter, y: y))
                        line.addLine(to: CGPoint(x: size.width, y: y))
                        context.stroke(line, with: .color(.black.opacity(0.04)), lineWidth: 0.5)
                    }
                }
                HStack(spacing: 0) {
                    Color.clear.frame(width: gutter, height: 26)
                    ForEach(days, id: \.self) { day in
                        Text(day).font(.system(size: 10, weight: .medium)).foregroundStyle(.secondary)
                            .frame(width: dayWidth, height: 26)
                    }
                }
                ForEach(0..<10, id: \.self) { row in
                    Text(String(format: "%02d", row + 1))
                        .font(.system(size: 9, weight: .medium, design: .rounded)).foregroundStyle(.tertiary)
                        .frame(width: gutter, height: rowHeight)
                        .offset(y: 32 + CGFloat(row) * rowHeight)
                }
                ForEach(lessons) { lesson in
                    VStack(spacing: 6) {
                        Text(lesson.title).font(.system(size: 12, weight: .medium)).lineLimit(3)
                        Text(lesson.room).font(.system(size: 9)).foregroundStyle(.secondary)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
                    .frame(width: dayWidth - 4, height: CGFloat(lesson.length) * rowHeight - 5)
                    .background(lesson.tint, in: RoundedRectangle(cornerRadius: 10))
                    .offset(x: gutter + CGFloat((lesson.day + (week - 1) % 2) % 7) * dayWidth + 2,
                            y: 32 + CGFloat(lesson.period) * rowHeight + 2)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("示例课表，第 \(week) 周")
    }
}
