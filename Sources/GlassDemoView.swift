import SwiftUI
import UniformTypeIdentifiers

struct GlassDemoView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("glassDemo.week") private var week = 1
    @State private var expansion: CGFloat = 0
    @State private var active: GlassControl?
    @State private var panelProgress: CGFloat = 0
    @State private var closing = false
    @State private var dragStart: CGFloat?
    @State private var dragAxis: DragAxis?
    @State private var importPresented = false
    @State private var selectedDate = Date()
    @State private var pickedName: String?
    @State private var importError: String?
    @State private var weekDirection = 1
    @Namespace private var glassNamespace

    private enum DragAxis { case horizontal, vertical }
    private var spring: Animation {
        reduceMotion ? .easeOut(duration: 0.12) : .spring(response: 0.42, dampingFraction: 0.77)
    }

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack(alignment: .topLeading) {
                ScrollView(showsIndicators: false) {
                    SampleTimetable(week: week)
                        .frame(height: max(630, size.height - 100))
                        .padding(.top, 80)
                        .padding(.bottom, 38)
                }
                .scrollBounceBehavior(.always)
                .blur(radius: max(GlassMotion.unit(expansion) * 4, GlassMotion.unit(panelProgress) * 9))
                .allowsHitTesting(expansion < 0.01 && active == nil)

                if expansion > 0.001 || active != nil {
                    Color.black.opacity(0.015 + 0.02 * Double(GlassMotion.unit(panelProgress)))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if active != nil { dismissPanel() }
                            else { withAnimation(spring) { expansion = 0 } }
                        }
                        .accessibilityLabel("收起")
                        .accessibilityIdentifier("dismissBackdrop")
                }

                GlassEffectContainer(spacing: 16) {
                    ZStack(alignment: .topLeading) {
                        ForEach(GlassControl.allCases) { control in
                            controlView(control, size: size)
                        }
                    }
                    .frame(width: size.width, height: size.height, alignment: .topLeading)
                }

                VStack {
                    Spacer()
                    Text(pickedName ?? "DEMO")
                        .font(.system(size: 10, weight: .medium))
                        .tracking(pickedName == nil ? 2 : 0)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .padding(.horizontal, 22)
                        .padding(.bottom, 8)
                        .accessibilityLabel(pickedName.map { "已选择文件：\($0)；演示版不解析课程" } ?? "示例课表")
                }
                .allowsHitTesting(false)
            }
            .frame(width: size.width, height: size.height)
            .clipped()
        }
        .background(Color.white.ignoresSafeArea())
        .tint(Color(red: 0, green: 0.40, blue: 1))
        .sensoryFeedback(.selection, trigger: week)
        .fileImporter(isPresented: $importPresented,
                      allowedContentTypes: [UTType(filenameExtension: "xls") ?? .spreadsheet]) { result in
            switch result {
            case .success(let url):
                let granted = url.startAccessingSecurityScopedResource()
                pickedName = url.lastPathComponent
                if granted { url.stopAccessingSecurityScopedResource() }
            case .failure(let error): importError = error.localizedDescription
            }
        }
        .alert("无法打开文件", isPresented: Binding(get: { importError != nil }, set: { if !$0 { importError = nil } })) {
            Button("好", role: .cancel) { importError = nil }
        } message: { Text(importError ?? "") }
        .onAppear {
            if ProcessInfo.processInfo.arguments.contains("--ui-testing") { week = 1 }
            week = min(30, max(1, week))
        }
    }

    @ViewBuilder
    private func controlView(_ control: GlassControl, size: CGSize) -> some View {
        let isActive = active == control
        let tile = GlassTile(control: control, size: size, expansion: expansion,
                             progress: isActive ? panelProgress : 0,
                             selected: isActive, week: week, weekDirection: weekDirection, namespace: glassNamespace,
                             selectedDate: $selectedDate, onWeek: selectWeek, onClose: dismissPanel)
            .zIndex(isActive ? 10 : control == .week ? 2 : 1)
        if isActive {
            // An expanded panel is a container, not its old outer tap target.
            // Keep the calendar's buttons as independent accessibility elements.
            tile.allowsHitTesting(!closing)
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("\(control.rawValue)Control")
        } else {
            let source = tile
                .allowsHitTesting(active == nil && (control == .week || expansion > 0.94))
                .accessibilityElement(children: .ignore)
                .accessibilityIdentifier("\(control.rawValue)Control")
                .accessibilityLabel(control == .week ? "教学周" : control == .date ? "开学日期" : "导入课表")
                .accessibilityValue(control == .week ? "W\(String(format: "%02d", week))" : "")
                .accessibilityAddTraits(.isButton)
                .accessibilityAction { activate(control) }
                .accessibilityAction(named: "展开操作") { withAnimation(spring) { expansion = 1 } }
            if control == .week {
                source.gesture(weekGesture)
            } else {
                source.onTapGesture { activate(control) }
            }
        }
    }

    private var weekGesture: some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .global)
            .onChanged { value in
                if dragStart == nil {
                    dragStart = expansion
                    dragAxis = abs(value.translation.height) > abs(value.translation.width) ? .vertical : .horizontal
                }
                if dragAxis == .vertical {
                    expansion = GlassMotion.rubberBand((dragStart ?? 0) + value.translation.height / GlassMotion.travel)
                }
            }
            .onEnded { value in
                let start = dragStart ?? expansion
                if dragAxis == .vertical {
                    let destination = GlassMotion.releasedExpansion(start: start, translation: value.translation.height,
                                                                   prediction: value.predictedEndTranslation.height)
                    withAnimation(spring) { expansion = destination }
                } else if dragAxis == .horizontal {
                    let next = GlassMotion.nextWeek(week, translation: value.translation.width,
                                                    prediction: value.predictedEndTranslation.width)
                    weekDirection = next >= week ? 1 : -1
                    withAnimation(.spring(response: 0.30, dampingFraction: 0.87)) {
                        week = next
                    }
                }
                dragStart = nil
                dragAxis = nil
            }
            .exclusively(before: TapGesture().onEnded { activate(.week) })
    }

    private func activate(_ control: GlassControl) {
        guard active == nil else { return }
        if control == .file {
            withAnimation(spring) { expansion = 0 }
            importPresented = true
            return
        }
        active = control
        // Keep the origin alive for one frame so the first panel frame is the ball.
        Task { @MainActor in
            await Task.yield()
            withAnimation(spring) { panelProgress = 1 }
        }
    }

    private func selectWeek(_ value: Int) {
        weekDirection = value >= week ? 1 : -1
        week = value
        dismissPanel()
    }

    private func dismissPanel() {
        guard active != nil, !closing else { return }
        closing = true
        withAnimation(spring, completionCriteria: .removed) {
            panelProgress = 0
        } completion: {
            active = nil
            closing = false
        }
    }
}

private struct GlassTile: View, Animatable {
    let control: GlassControl
    let size: CGSize
    var expansion: CGFloat
    var progress: CGFloat
    let selected: Bool
    let week: Int
    let weekDirection: Int
    let namespace: Namespace.ID
    @Binding var selectedDate: Date
    let onWeek: (Int) -> Void
    let onClose: () -> Void

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(expansion, progress) }
        set { expansion = newValue.first; progress = newValue.second }
    }

    var body: some View {
        let source = GlassMotion.control(control, size: size, top: 8, expansion: expansion)
        let target = GlassMotion.panel(control, size: size, top: 8, bottom: 8)
        let frame = selected ? GlassMotion.morph(source, target, progress: progress) : source
        let growth = GlassMotion.smooth(GlassMotion.segment(progress, 0.03, 1))
        let radius = min(source.height, source.width) / 2 + (28 - min(source.height, source.width) / 2) * growth
        let contentAlpha = GlassMotion.segment(progress, 0.56, 0.93)
        let labelAlpha = (1 - GlassMotion.segment(progress, 0.15, 0.48)) *
            (control == .week ? 1 : GlassMotion.segment(expansion, 0.38, 0.88))
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        ZStack {
            Color.clear
            symbol
                .opacity(Double(labelAlpha))
                .accessibilityHidden(true)
            if selected {
                panelBody
                    .frame(width: target.width, height: target.height)
                    .fixedSize()
                    .opacity(Double(contentAlpha))
                    .allowsHitTesting(contentAlpha > 0.98)
                    .accessibilityHidden(contentAlpha < 0.98)
            }
        }
        .frame(width: max(1, frame.width), height: max(1, frame.height))
        .clipShape(shape)
        .glassEffect(.regular.interactive(), in: shape)
        .glassEffectID(control.rawValue, in: namespace)
        .contentShape(shape)
        .position(x: frame.midX, y: frame.midY)
    }

    @ViewBuilder private var symbol: some View {
        switch control {
        case .week:
            ZStack {
                Text("W\(String(format: "%02d", week))")
                    .font(.system(size: 16, weight: .medium)).monospacedDigit()
                    .id(week)
                    .transition(.asymmetric(insertion: .move(edge: weekDirection > 0 ? .trailing : .leading).combined(with: .opacity),
                                            removal: .move(edge: weekDirection > 0 ? .leading : .trailing).combined(with: .opacity)))
            }
            .frame(width: 58, height: 32).clipped()
        case .file: Image(systemName: "square.and.arrow.down").font(.system(size: 19, weight: .medium))
        case .date: Image(systemName: "calendar").font(.system(size: 19, weight: .medium))
        }
    }

    @ViewBuilder private var panelBody: some View {
        if control == .week {
            VStack(spacing: 10) {
                HStack {
                    Text("W\(String(format: "%02d", week))").font(.system(size: 26, weight: .semibold)).monospacedDigit()
                    Spacer()
                    closeButton
                }
                .padding(.bottom, 8)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 5), spacing: 6) {
                    ForEach(1...30, id: \.self) { value in
                        Button { onWeek(value) } label: {
                            Text(String(format: "%02d", value)).font(.system(size: 15, weight: .medium)).monospacedDigit()
                                .frame(maxWidth: .infinity).frame(height: 36)
                                .foregroundStyle(value == week ? Color.white : Color.primary)
                                .background(value == week ? Color.accentColor : Color.clear,
                                            in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("week-option-\(value)")
                    }
                }
            }
            .padding(22)
            .accessibilityIdentifier("weekPanel")
        } else if control == .date {
            VStack(spacing: 8) {
                HStack {
                    Text("W01").font(.system(size: 24, weight: .semibold))
                    Spacer()
                    closeButton
                }
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
                ScrollView(showsIndicators: false) {
                    DatePicker("开学日期", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                }
                .frame(maxHeight: .infinity)
                Button(action: onClose) {
                    Image(systemName: "checkmark").font(.system(size: 17, weight: .semibold))
                        .frame(width: 44, height: 38)
                }
                .buttonStyle(.glassProminent)
                .accessibilityLabel("确认日期")
                .fixedSize()
                .layoutPriority(1)
            }
            .padding(20)
            .accessibilityIdentifier("datePanel")
        }
    }

    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark").font(.system(size: 15, weight: .semibold))
                .frame(width: 38, height: 38)
                .foregroundStyle(.secondary)
                .background(.black.opacity(0.045), in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("关闭")
        .accessibilityIdentifier("closePanel")
    }
}
