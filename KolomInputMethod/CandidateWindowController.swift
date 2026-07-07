import Cocoa
import SwiftUI

// MARK: - CandidateWindowController
// Displays a floating NSPanel of Bengali word candidates near the text cursor.
// Pure presentation layer — it never queries the dictionary or ranks words.
//
// @MainActor: All UI operations must run on the main thread.
// Declaring @MainActor lets Swift 6's concurrency checker verify this and
// eliminates the "Task-isolated self captured by main-actor-isolated closure"
// error that arises when mixing DispatchQueue.main.async with actor isolation.

@MainActor
final class CandidateWindowController: NSObject {

    // MARK: - Panel

    private var panel: NSPanel?
    private var viewModel = CandidateViewModel()

    // MARK: - State

    // State is purely managed by the view model now


    // MARK: - Show / Hide

    func show(candidates: [String], selectedIndex: Int, near rect: NSRect) {
        Task { @MainActor [weak self] in
            guard let self else { return }

            if self.panel == nil {
                self.createPanel()
            }
            guard let panel = self.panel else { return }

            self.viewModel.candidates = candidates
            self.viewModel.selectedIndex = selectedIndex

            // Sync the root view directly to force a synchronous layout measurement
            guard let hostingView = panel.contentView as? NSHostingView<CandidateWindowView> else { return }
            hostingView.rootView = CandidateWindowView(viewModel: self.viewModel)
            
            let fittingSize = hostingView.fittingSize
            let panelWidth = max(fittingSize.width, 50)
            let panelHeight = max(fittingSize.height, 30)

            let origin = NSPoint(x: rect.minX, y: rect.minY - panelHeight - 4)
            let frame = NSRect(origin: origin, size: CGSize(width: panelWidth, height: panelHeight))

            panel.setFrame(frame, display: false)
            panel.orderFront(nil)
        }
    }

    func hide() {
        Task { @MainActor [weak self] in
            self?.panel?.orderOut(nil)
            self?.viewModel.selectedIndex = 0
        }
    }

    // CandidateWindowController is purely presentation. Navigation logic has been moved to InputSession.

    // MARK: - Panel Creation

    private func createPanel() {
        let p = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 240, height: 44),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: true
        )

        let hostingView = NSHostingView(rootView: CandidateWindowView(viewModel: viewModel))
        hostingView.translatesAutoresizingMaskIntoConstraints = false

        p.contentView = hostingView
        p.level = .floating
        p.isOpaque = false
        p.backgroundColor = .clear
        p.hasShadow = true
        p.collectionBehavior = [.canJoinAllSpaces, .transient, .ignoresCycle]
        p.animationBehavior = .none

        self.panel = p
    }
}

// MARK: - CandidateViewModel

@MainActor
final class CandidateViewModel: ObservableObject {
    @Published var candidates: [String] = []
    @Published var selectedIndex: Int = 0
}

// MARK: - CandidateWindowView

struct CandidateWindowView: View {

    @ObservedObject var viewModel: CandidateViewModel

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(viewModel.candidates.enumerated()), id: \.offset) { index, candidate in
                candidateRow(index: index, word: candidate)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.97))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
        .fixedSize() // Ensure it calculates its own ideal size without expanding
    }

    @ViewBuilder
    private func candidateRow(index: Int, word: String) -> some View {
        let isSelected = index == viewModel.selectedIndex

        HStack(spacing: 6) {
            Text("\(index + 1)")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(isSelected ? .white.opacity(0.75) : Color(NSColor.tertiaryLabelColor))

            Text(word)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(isSelected ? .white : .primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Group {
                if isSelected {
                    RoundedRectangle(cornerRadius: 7).fill(Color.accentColor)
                } else {
                    Color.clear
                }
            }
        )
        .contentShape(Rectangle())
    }
}
