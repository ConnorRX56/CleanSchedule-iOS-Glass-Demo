import AppKit
import Foundation

// A small code-drawn calendar mark; no downloaded artwork or font files.
let canvas = NSSize(width: 1024, height: 1024)
let image = NSImage(size: canvas)
image.lockFocus()
let whole = NSRect(origin: .zero, size: canvas)
NSGradient(starting: NSColor(calibratedRed: 0.13, green: 0.56, blue: 1, alpha: 1),
           ending: NSColor(calibratedRed: 0.0, green: 0.29, blue: 0.88, alpha: 1))!.draw(in: whole, angle: 75)
let plate = NSBezierPath(roundedRect: NSRect(x: 180, y: 188, width: 664, height: 656), xRadius: 126, yRadius: 126)
NSColor.white.withAlphaComponent(0.96).setFill()
plate.fill()
let ink = NSColor(calibratedRed: 0.06, green: 0.35, blue: 0.85, alpha: 1)
ink.setFill()
for x in [CGFloat(342), CGFloat(682)] {
    NSBezierPath(roundedRect: NSRect(x: x - 25, y: 773, width: 50, height: 121), xRadius: 25, yRadius: 25).fill()
}
ink.withAlphaComponent(0.18).setFill()
NSBezierPath(roundedRect: NSRect(x: 258, y: 690, width: 508, height: 14), xRadius: 7, yRadius: 7).fill()
for row in 0..<3 {
    for column in 0..<3 {
        let point = NSRect(x: CGFloat(283 + column * 178), y: CGFloat(283 + row * 130), width: 100, height: 72)
        (row == 1 && column == 1 ? ink : ink.withAlphaComponent(0.20)).setFill()
        NSBezierPath(roundedRect: point, xRadius: 22, yRadius: 22).fill()
    }
}
image.unlockFocus()
let bitmap = NSBitmapImageRep(data: image.tiffRepresentation!)!
let png = bitmap.representation(using: .png, properties: [:])!
let target = URL(fileURLWithPath: CommandLine.arguments[1])
try FileManager.default.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
try png.write(to: target, options: .atomic)
print("Created calendar icon")
