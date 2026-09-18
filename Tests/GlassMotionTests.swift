import XCTest
@testable import CleanScheduleGlass

final class GlassMotionTests: XCTestCase {
    private let size = CGSize(width: 393, height: 760)

    func testClosedWeekIsCenteredAndOtherShapesFitInsideIt() {
        let week = GlassMotion.control(.week, size: size, top: 8, expansion: 0)
        XCTAssertEqual(week.midX, size.width / 2)
        XCTAssertEqual(week.width, 96)
        for kind in [GlassControl.file, .date] {
            XCTAssertTrue(week.contains(GlassMotion.control(kind, size: size, top: 8, expansion: 0)))
        }
    }
    func testOpenControlsAreDistinctCirclesWithinTheScreen() {
        let shapes = GlassControl.allCases.map { GlassMotion.control($0, size: size, top: 8, expansion: 1) }
        for shape in shapes {
            XCTAssertEqual(shape.width, 52)
            XCTAssertEqual(shape.width, shape.height)
            XCTAssertTrue(CGRect(origin: .zero, size: size).contains(shape))
        }
        XCTAssertLessThan(shapes[0].maxX + 16, shapes[1].minX)
        XCTAssertLessThan(shapes[1].maxX + 16, shapes[2].minX)
    }
    func testReleaseUsesDirectionAndPrediction() {
        XCTAssertEqual(GlassMotion.releasedExpansion(start: 0, translation: 12, prediction: 12), 0)
        XCTAssertEqual(GlassMotion.releasedExpansion(start: 0, translation: 12, prediction: 90), 1)
        XCTAssertEqual(GlassMotion.releasedExpansion(start: 1, translation: -60, prediction: -90), 0)
    }
    func testWeekLimitsAndSmallMovement() {
        XCTAssertEqual(GlassMotion.nextWeek(1, translation: 80, prediction: 80), 1)
        XCTAssertEqual(GlassMotion.nextWeek(30, translation: -80, prediction: -80), 30)
        XCTAssertEqual(GlassMotion.nextWeek(8, translation: 5, prediction: 7), 8)
        XCTAssertEqual(GlassMotion.nextWeek(8, translation: -80, prediction: -85), 9)
    }
    func testMorphEndpointsAndContinuity() {
        let source = GlassMotion.control(.week, size: size, top: 8, expansion: 1)
        let target = GlassMotion.panel(.week, size: size, top: 8, bottom: 8)
        let start = GlassMotion.morph(source, target, progress: 0)
        let end = GlassMotion.morph(source, target, progress: 1)
        XCTAssertEqual(start, source)
        XCTAssertEqual(end.width, target.width, accuracy: 0.001)
        XCTAssertEqual(end.midY, target.midY, accuracy: 0.001)
        let a = GlassMotion.morph(source, target, progress: 0.89999)
        let b = GlassMotion.morph(source, target, progress: 0.90001)
        XCTAssertLessThan(abs(a.width - b.width), 0.1)
        XCTAssertLessThan(abs(a.midY - b.midY), 0.1)
    }
    func testOverdragIsBoundedWithoutASnapAtTheEnds() {
        XCTAssertEqual(GlassMotion.rubberBand(0), 0)
        XCTAssertEqual(GlassMotion.rubberBand(1), 1)
        XCTAssertGreaterThan(GlassMotion.rubberBand(-100), -0.091)
        XCTAssertLessThan(GlassMotion.rubberBand(100), 1.091)
    }
}
