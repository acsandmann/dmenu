import Cocoa

private class WeakRef<T: AnyObject> {
	weak var value: T?
	init(_ value: T) { self.value = value }
}

final class row: NSTableRowView {
	private var trackingArea: NSTrackingArea?
	private static var currentHover: WeakRef<row>?

	private var isHovered = false {
		didSet {
			guard oldValue != isHovered else { return }
			needsDisplay = true
		}
	}

	override func updateTrackingAreas() {
		super.updateTrackingAreas()

		if let trackingArea = trackingArea {
			removeTrackingArea(trackingArea)
		}

		trackingArea = NSTrackingArea(
			rect: bounds,
			options: [.mouseEnteredAndExited, .activeInKeyWindow],
			owner: self,
			userInfo: nil
		)
		addTrackingArea(trackingArea!)
	}

	override func mouseEntered(with event: NSEvent) {
		super.mouseEntered(with: event)

		Self.currentHover?.value?.isHovered = false
		Self.currentHover = WeakRef(self)
		isHovered = true
	}

	override func mouseExited(with event: NSEvent) {
		super.mouseExited(with: event)

		if Self.currentHover?.value === self {
			Self.currentHover = nil
		}
		isHovered = false
	}

	private static let selectionPath = NSBezierPath()
	private static let hoverPath = NSBezierPath()

	override func drawSelection(in _: NSRect) {
		guard selectionHighlightStyle != .none else { return }
		drawRowBackground(isSelected: true)
	}

	override func drawBackground(in _: NSRect) {
		if isHovered && !isSelected {
			drawRowBackground(isSelected: false)
		}
	}

	private func drawRowBackground(isSelected: Bool) {
		let rect = bounds.insetBy(dx: 2, dy: 2)
		let path = NSBezierPath(roundedRect: rect, xRadius: 6, yRadius: 6)

		if isSelected {
			NSColor.controlAccentColor.withAlphaComponent(0.23).setFill()
			path.fill()

			NSColor.controlAccentColor.withAlphaComponent(0.33).setStroke()
			path.lineWidth = 1.0
			path.stroke()
		} else {
			NSColor.controlAccentColor.withAlphaComponent(0.1).setFill()
			path.fill()

			NSColor.controlAccentColor.withAlphaComponent(0.25).setStroke()
			path.lineWidth = 0.5
			path.stroke()
		}
	}
}
