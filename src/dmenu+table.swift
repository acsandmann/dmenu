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

		let txt = textfield()
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
		row()
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
