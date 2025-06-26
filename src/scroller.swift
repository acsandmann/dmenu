import Cocoa

final class scroller: NSScroller {
	var padding: CGFloat = 0

	override func drawKnobSlot(in _: NSRect, highlight _: Bool) {}

	override func drawKnob() {
		let prop = knobProportion
		let shouldShow = prop > 0 && prop < 1

		guard shouldShow else { return }

		let pad: CGFloat = 4
		let track = bounds.insetBy(dx: pad, dy: pad)

		let knobH = track.height * prop
		let y = track.minY + (track.height - knobH) * CGFloat(doubleValue)
		let knobR = NSRect(
			x: track.minX,
			y: y,
			width: track.width,
			height: knobH
		)

		let path = NSBezierPath(
			roundedRect: knobR,
			xRadius: knobR.width / 2,
			yRadius: knobR.width / 2
		)
		NSColor.secondaryLabelColor
			.withAlphaComponent(0.7)
			.setFill()
		path.fill()
	}
}
