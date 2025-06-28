import Cocoa

extension dmenu {
	func numberOfRows(in _: NSTableView) -> Int { filteredItems.count }

	func tableView(
		_ tableView: NSTableView,
		viewFor _: NSTableColumn?,
		row: Int
	) -> NSView? {
		let item = filteredItems[row]
		let pad: CGFloat = config.sidePadding / 2

		let txt = textfield()
		txt.itemFontSize = config.itemFontSize
		txt.isBordered = false
		txt.drawsBackground = false
		txt.isEditable = false
		txt.lineBreakMode = .byTruncatingTail
		txt.font = .systemFont(ofSize: config.itemFontSize)
		txt.textColor = .labelColor

		let tokens =
			searchField?.stringValue
			.lowercased()
			.split(whereSeparator: \.isWhitespace)
			.compactMap { $0.isEmpty ? nil : String($0) } ?? []
		if !tokens.isEmpty {
			txt.attributedStringValue = txt.highlight(item: item, tokens: tokens)
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
		// Disable movement in lock mode
		//guard !config.lock else { return }
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
		// Disable row selection in lock mode
		//guard !config.lock else { return }
		tableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
		tableView.scrollRowToVisible(index)
	}

	func selectCurrentRow() {
		// Disable selection output in lock mode
		//guard !config.lock else { return }
		let r = tableView.selectedRow
		guard r >= 0, r < filteredItems.count else { return }
		fflush(stdout)
		NSApp.terminate(nil)
	}

	@objc func handleClick() {
		// Disable click handling in lock mode
		//guard !config.lock else { return }
		selectCurrentRow()
	}
}
