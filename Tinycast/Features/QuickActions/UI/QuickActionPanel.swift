import AppKit
import Carbon.HIToolbox

/// Keys go through `sendEvent`, so ⌘C, Esc and ↵ need no focused subview to reach the panel.
final class QuickActionPanel: NSPanel, AnimatedPanel {
    enum Key {
        case replace
        case copy
        case cancel
    }

    var onKey: ((Key) -> Void)?

    init(content: NSView) {
        super.init(
            contentRect: NSRect(origin: .zero, size: content.frame.size),
            styleMask: [.borderless, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        isFloatingPanel = true
        // Above the palette, below a dialog: a failure report must still land on top of it.
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isMovableByWindowBackground = true
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        followMotion()
        isReleasedWhenClosed = false
        isRestorable = false
        contentView = content
    }

    override func sendEvent(_ event: NSEvent) {
        guard event.type == .keyDown, let onKey else {
            super.sendEvent(event)
            return
        }
        // ⌘C, never a bare C: an input method captures letter keys for composition, so a bare C
        // never reaches a key window; Esc and ↵ are control keys, which it passes through.
        if event.modifierFlags.contains(.command) {
            guard Int(event.keyCode) == kVK_ANSI_C else {
                super.sendEvent(event)
                return
            }
            onKey(.copy)
            return
        }
        switch Int(event.keyCode) {
        case kVK_Escape:
            onKey(.cancel)
        case kVK_Return, kVK_ANSI_KeypadEnter:
            onKey(.replace)
        default:
            super.sendEvent(event)
        }
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
