import Cocoa

final class scroller: NSScroller {
	override func drawKnobSlot(in _: NSRect, highlight _: Bool) {}

	override func drawKnob() {
		let pad: CGFloat = 2
		let track = bounds.insetBy(dx: pad, dy: pad)

		let prop = knobProportion
		guard prop > 0, prop < 1 else { return }

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
			// .withAlphaComponent(0.65)
			.setFill()
		path.fill()
	}
}
