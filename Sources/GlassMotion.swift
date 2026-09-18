import Foundation

enum GlassControl: String, CaseIterable, Identifiable {
    case file, week, date
    var id: String { rawValue }
    var index: CGFloat { self == .file ? -1 : self == .date ? 1 : 0 }
}

enum GlassMotion {
    static let travel: CGFloat = 74
    static func unit(_ value: CGFloat) -> CGFloat { min(1, max(0, value)) }
    static func segment(_ p: CGFloat, _ start: CGFloat, _ end: CGFloat) -> CGFloat {
        unit((p - start) / (end - start))
    }
    static func smooth(_ p: CGFloat) -> CGFloat { let t = unit(p); return t * t * (3 - 2 * t) }
    static func rubberBand(_ raw: CGFloat) -> CGFloat {
        if raw < 0 { return -0.09 * (1 - 1 / (1 - raw * 8)) }
        if raw > 1 { return 1 + 0.09 * (1 - 1 / (1 + (raw - 1) * 8)) }
        return raw
    }
    static func releasedExpansion(start: CGFloat, translation: CGFloat, prediction: CGFloat) -> CGFloat {
        let projected = translation + (prediction - translation) * 0.45
        return start + projected / travel >= 0.5 ? 1 : 0
    }
    static func nextWeek(_ week: Int, translation: CGFloat, prediction: CGFloat) -> Int {
        let projected = translation + (prediction - translation) * 0.35
        if projected < -32 { return min(30, week + 1) }
        if projected > 32 { return max(1, week - 1) }
        return week
    }
    static func rect(center: CGPoint, width: CGFloat, height: CGFloat) -> CGRect {
        CGRect(x: center.x - width / 2, y: center.y - height / 2, width: width, height: height)
    }
    static func control(_ control: GlassControl, size: CGSize, top: CGFloat, expansion: CGFloat) -> CGRect {
        let p = unit(expansion)
        let spread = min(76, max(0, (size.width - 84) / 2))
        let center = CGPoint(x: size.width / 2 + control.index * spread * smooth(p),
                             y: top + 28 + travel * expansion + abs(control.index) * sin(.pi * p) * 5)
        let width: CGFloat = control == .week ? 96 + (52 - 96) * smooth(p) : 18 + 34 * smooth(p)
        let height: CGFloat = control == .week ? 44 + 8 * smooth(p) : width
        return rect(center: center, width: width, height: height)
    }
    static func panel(_ control: GlassControl, size: CGSize, top: CGFloat, bottom: CGFloat) -> CGRect {
        let height: CGFloat = control == .date ? 520 : 364
        let visibleHeight = max(80, size.height - top - bottom - 32)
        return rect(center: CGPoint(x: size.width / 2, y: top + (size.height - top - bottom) / 2),
                    width: min(350, size.width - 32), height: min(height, visibleHeight))
    }
    static func morph(_ source: CGRect, _ target: CGRect, progress: CGFloat) -> CGRect {
        let p = unit(progress)
        let growth = smooth(segment(p, 0.03, 1))
        let move = smooth(segment(p, 0.08, 1))
        let swell = sin(.pi * segment(p, 0, 0.32)) * 0.07
        let bounce = min(0.08, max(0, progress - 1))
        let center = CGPoint(x: source.midX + (target.midX - source.midX) * move,
                             y: source.midY + (target.midY - source.midY) * move)
        return rect(center: center,
                    width: source.width * (1 + swell) + (target.width - source.width) * growth + target.width * bounce * 0.15,
                    height: source.height * (1 + swell) + (target.height - source.height) * growth - target.height * bounce * 0.12)
    }
}
