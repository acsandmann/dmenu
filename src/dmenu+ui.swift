import Cocoa

class Scroller: NSScroller {
	override func drawKnobSlot(in slotRect: NSRect, highlight: Bool) {}

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
			height: knobH)

		let path = NSBezierPath(
			roundedRect: knobR,
			xRadius: knobR.width / 2,
			yRadius: knobR.width / 2
		)
		NSColor.tertiaryLabelColor
			.withAlphaComponent(0.35)
			.setFill()
		path.fill()
	}
}

extension dmenu {
	func buildUI() {
		let screen = NSScreen.main!.frame
		let width = config.width
		let height = config.totalHeight
		let borderRadius = config.borderRadius
		let searchH = config.searchH
		let itemH = config.itemH
		let searchFieldHeight = config.searchFieldHeight
		let sidePadding = config.sidePadding
		let iconSize = config.iconSize

		window = NSWindow(
			contentRect: NSRect(
				x: (screen.width - width) / 2,
				y: (screen.height - height) / 2,
				width: width, height: height
			),
			styleMask: [.titled, .fullSizeContentView, .borderless],
			backing: .buffered, defer: false
		)
		window.isOpaque = false
		window.backgroundColor = .clear
		window.level = .floating
		window.titleVisibility = .hidden
		window.titlebarAppearsTransparent = true

		NSApp.setActivationPolicy(.regular)
		window.center()
		window.makeKeyAndOrderFront(nil)

		let container = NSView(frame: window.contentView!.bounds)
		container.wantsLayer = true
		container.layer?.cornerRadius = borderRadius
		container.layer?.borderWidth = 1
		container.layer?.borderColor = NSColor.separatorColor.cgColor
		container.autoresizingMask = [.width, .height]
		window.contentView?.addSubview(container)

		let blur = NSVisualEffectView(frame: container.bounds)
		blur.autoresizingMask = [.width, .height]
		blur.material = .hudWindow
		blur.blendingMode = .behindWindow
		blur.state = .active
		blur.layer?.cornerRadius = borderRadius
		container.addSubview(blur)

		let gradient = CAGradientLayer()
		gradient.frame = container.bounds
		gradient.colors = [
			NSColor.windowBackgroundColor.withAlphaComponent(0.15).cgColor,
			NSColor.windowBackgroundColor.withAlphaComponent(0.08).cgColor,
		]
		gradient.cornerRadius = borderRadius

		let overlay = NSView(frame: container.bounds)
		overlay.wantsLayer = true
		overlay.layer?.addSublayer(gradient)
		overlay.alphaValue = 0.5
		overlay.autoresizingMask = [.width, .height]
		container.addSubview(overlay)

		let searchAreaTopY = height - searchH
		let searchAreaCenterY = searchAreaTopY + (searchH / 2.0)
		let ySearch = searchAreaCenterY - (searchFieldHeight / 2.0) - 4
		let leadingX: CGFloat = config.showIcon ? config.iconPadding : config.textPadding

		if config.showIcon {
			let iconY = searchAreaCenterY - (iconSize / 2.0)
			let iconX = (config.iconPadding - iconSize) / 2.0

			let icon = NSImageView(
				frame: NSRect(
					x: iconX,
					y: iconY,
					width: iconSize, height: iconSize))
			icon.image = NSImage(
				systemSymbolName: "magnifyingglass",
				accessibilityDescription: nil)?
				.withSymbolConfiguration(.init(pointSize: iconSize, weight: .light))
			icon.contentTintColor = .secondaryLabelColor
			container.addSubview(icon)
		}

		searchField = NSSearchField(
			frame: NSRect(
				x: leadingX,
				y: ySearch,
				width: width - leadingX - config.textPadding,
				height: searchFieldHeight))
		searchField.placeholderString = config.placeholder
		searchField.focusRingType = .none
		searchField.delegate = self
		(searchField.cell as? NSSearchFieldCell)?.font = .systemFont(ofSize: config.searchFontSize)
		searchField.isBordered = false
		searchField.drawsBackground = false
		if let cell = searchField.cell as? NSSearchFieldCell {
			cell.searchButtonCell = nil
			cell.cancelButtonCell = nil
		}
		container.addSubview(searchField)

		let sep = NSView(
			frame: NSRect(
				x: 0, y: height - searchH,
				width: width, height: 1)
		)
		sep.wantsLayer = true
		sep.layer?.backgroundColor = NSColor.separatorColor.cgColor
		sep.autoresizingMask = [.width]
		container.addSubview(sep)

		let scroll = NSScrollView(
			frame: NSRect(
				x: sidePadding,
				y: sidePadding,
				width: width - 2 * sidePadding,
				height: height - searchH - sidePadding
			)
		)
		scroll.drawsBackground = false
		scroll.hasVerticalScroller = true
		scroll.scrollerStyle = .overlay
		scroll.autohidesScrollers = true

		let custom = Scroller(frame: .zero)
		custom.scrollerStyle = .overlay
		scroll.verticalScroller = custom

		tableView = NSTableView(frame: scroll.bounds)
		tableView.autoresizingMask = [.width, .height]
		tableView.columnAutoresizingStyle = .lastColumnOnlyAutoresizingStyle
		tableView.headerView = nil
		tableView.rowHeight = itemH
		tableView.backgroundColor = .clear
		tableView.selectionHighlightStyle = .regular
		tableView.delegate = self
		tableView.dataSource = self

		let col = NSTableColumn(identifier: .init("Item"))
		col.resizingMask = .autoresizingMask
		tableView.addTableColumn(col)

		scroll.documentView = tableView
		container.addSubview(scroll)
	}
}
