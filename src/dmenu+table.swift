import Cocoa

extension dmenu {
	func createHighlightedText(item: String, tokens: [String]) -> NSAttributedString {
		let attr = NSMutableAttributedString(string: item)
		let baseFont = NSFont.monospacedSystemFont(ofSize: config.itemFontSize, weight: .regular)

		attr.addAttributes(
			[
				.font: baseFont,
				.foregroundColor: NSColor.labelColor.withAlphaComponent(0.8),
				.kern: 0.5,
			], range: NSRange(location: 0, length: item.count)
		)

		let lowerItem = item.lowercased()
		for token in tokens {
			var searchStart = lowerItem.startIndex
			while let range = lowerItem.range(of: token, range: searchStart ..< lowerItem.endIndex) {
				let nsRange = NSRange(range, in: item)

				let highlightColor = NSColor.systemCyan
				attr.addAttributes(
					[
						.backgroundColor: highlightColor.withAlphaComponent(0.2),
						.font: NSFont.monospacedSystemFont(
							ofSize: config.itemFontSize, weight: .bold
						),
						.foregroundColor: highlightColor,
						.kern: 0.8,
						.shadow: {
							let shadow = NSShadow()
							shadow.shadowColor = highlightColor.withAlphaComponent(0.7)
							shadow.shadowOffset = NSSize(width: 0, height: 0)
							shadow.shadowBlurRadius = 3.0
							return shadow
						}(),
					], range: nsRange
				)

				searchStart = range.upperBound
			}
		}

		return attr
	}

	func numberOfRows(in _: NSTableView) -> Int { filteredItems.count }

	func tableView(
		_ tableView: NSTableView,
		viewFor _: NSTableColumn?,
		row: Int
	) -> NSView? {
		let item = filteredItems[row]
		let pad: CGFloat = config.sidePadding / 2

		let txt = dmenu_textfield()
		txt.isBordered = false
		txt.drawsBackground = false
		txt.isEditable = false
		txt.lineBreakMode = .byTruncatingTail
		txt.font = .systemFont(ofSize: config.itemFontSize)
		txt.textColor = .labelColor

		let tokens = searchField.stringValue
			.lowercased()
			.split(whereSeparator: \.isWhitespace)
		if !tokens.isEmpty {
			let attr = createHighlightedText(item: item, tokens: tokens.map(String.init))
			txt.attributedStringValue = attr
		} else {
			txt.stringValue = item
		}

		let cont = NSView(
			frame: NSRect(
				x: 0, y: 0,
				width: tableView.frame.width,
				height: tableView.rowHeight
			))
		let textSize = txt.intrinsicContentSize
		let yOffset = (cont.bounds.height - textSize.height) / 2
		txt.frame = NSRect(
			x: pad,
			y: yOffset,
			width: cont.bounds.width - 2 * pad,
			height: textSize.height
		)
		cont.addSubview(txt)
		return cont
	}

	func tableView(_: NSTableView, rowViewForRow _: Int) -> NSTableRowView? {
		dmenu_row()
	}

	func moveSelection(offset: Int) {
		guard !filteredItems.isEmpty else { return }
		let currentSelection = tableView.selectedRow
		let count = filteredItems.count
		var next = currentSelection + offset

		if next < 0 {
			next = count - 1
		} else if next >= count {
			next = 0
		}
		selectRow(index: next)
	}

	func selectRow(index: Int) {
		guard !filteredItems.isEmpty else { return }
		tableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
		tableView.scrollRowToVisible(index)
	}

	func selectCurrentRow() {
		let r = tableView.selectedRow
		guard r >= 0, r < filteredItems.count else { return }
		print(filteredItems[r])
		fflush(stdout)
		NSApp.terminate(nil)
	}

	@objc func handleClick() { selectCurrentRow() }
}

final class dmenu_textfield: NSTextField {
	override var allowsVibrancy: Bool { false }

	override var stringValue: String {
		didSet { applyBaseAttributes() }
	}

	override var attributedStringValue: NSAttributedString {
		didSet {}
	}

	private func applyBaseAttributes() {
		guard !stringValue.isEmpty else { return }

		let baseFont = NSFont.monospacedSystemFont(ofSize: font?.pointSize ?? 13, weight: .regular)
		let attr = NSMutableAttributedString(string: stringValue)

		attr.addAttributes(
			[
				.font: baseFont,
				.foregroundColor: NSColor.labelColor.withAlphaComponent(0.8),
				.kern: 0.5,
			], range: NSRange(location: 0, length: stringValue.count)
		)

		super.attributedStringValue = attr
	}
}

final class dmenu_row: NSTableRowView {
	private var trackingArea: NSTrackingArea?
	private static var currentHover: WeakRef<dmenu_row>?

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

private class WeakRef<T: AnyObject> {
	weak var value: T?
	init(_ value: T) { self.value = value }
}
