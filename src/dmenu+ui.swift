import Cocoa
import QuartzCore

extension dmenu {
	func buildUI() {
		let screen = NSScreen.main!.frame
		let width = config.width
		let height = config.totalHeight
		let borderRadius = config.borderRadius
		let searchH = config.searchH
		let itemH = config.itemH
		let searchFieldH = config.searchFieldHeight
		let sidePadding = config.sidePadding
		let iconSize = config.iconSize

		window = NSWindow(
			contentRect: NSRect(
				x: (screen.width - width) / 2,
				y: (screen.height - height) / 2,
				width: width,
				height: height
			),
			styleMask: [.titled, .fullSizeContentView, .borderless],
			backing: .buffered,
			defer: false
		)

		window.isOpaque = false
		window.backgroundColor = .clear
		window.hasShadow = true
		window.level = .floating
		window.titleVisibility = .hidden
		window.titlebarAppearsTransparent = true
		window.isMovableByWindowBackground = true

		NSApp.setActivationPolicy(.regular)
		window.center()
		window.makeKeyAndOrderFront(nil)

		let rootBlur = NSVisualEffectView(frame: window.contentView!.bounds)
		rootBlur.autoresizingMask = [.width, .height]
		rootBlur.material = .hudWindow
		rootBlur.blendingMode = .behindWindow
		rootBlur.state = .active
		rootBlur.wantsLayer = true
		rootBlur.layer?.cornerRadius = borderRadius
		rootBlur.layer?.masksToBounds = true
		window.contentView = rootBlur

		let sheen = CAGradientLayer()
		sheen.frame = rootBlur.bounds
		sheen.cornerRadius = borderRadius
		sheen.colors = [
			NSColor.windowBackgroundColor.withAlphaComponent(0.15).cgColor,
			NSColor.windowBackgroundColor.withAlphaComponent(0.03).cgColor,
		]
		sheen.startPoint = .init(x: 0.5, y: 0)
		sheen.endPoint = .init(x: 0.5, y: 1)
		rootBlur.layer?.addSublayer(sheen)

		if let shadowLayer = rootBlur.superview?.layer {
			shadowLayer.masksToBounds = false
			shadowLayer.shadowColor = NSColor.black.cgColor
			shadowLayer.shadowOpacity = 0.18
			shadowLayer.shadowRadius = 40
			shadowLayer.shadowOffset = .zero
		}

		let searchAreaTopY = height - searchH
		let searchAreaCenterY = searchAreaTopY + searchH / 2
		let ySearch = searchAreaCenterY - searchFieldH / 2 - 4
		let leadingX: CGFloat = config.showIcon ? config.iconPadding : config.textPadding

		if config.showIcon {
			let iconY = searchAreaCenterY - iconSize / 2
			let iconX = (config.iconPadding - iconSize) / 2

			let iconView = NSImageView(
				frame: .init(x: iconX, y: iconY, width: iconSize, height: iconSize))
			iconView.image = NSImage(
				systemSymbolName: "magnifyingglass", accessibilityDescription: nil
			)?
			.withSymbolConfiguration(.init(pointSize: iconSize, weight: .light))
			iconView.contentTintColor = .secondaryLabelColor
			rootBlur.addSubview(iconView)
		}

		searchField = NSSearchField(
			frame: .init(
				x: leadingX,
				y: ySearch,
				width: width - leadingX - config.textPadding,
				height: searchFieldH
			))
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
		rootBlur.addSubview(searchField)

		let sep = NSView(
			frame: .init(
				x: sidePadding * 2,
				y: height - searchH,
				width: width - (4 * sidePadding),
				height: 1
			))
		sep.wantsLayer = true
		sep.layer?.backgroundColor = NSColor.separatorColor.cgColor
		sep.autoresizingMask = [.width]
		rootBlur.addSubview(sep)

		let scroll = NSScrollView(
			frame: .init(
				x: sidePadding,
				y: sidePadding,
				width: width - 2 * sidePadding,
				height: height - searchH - sidePadding
			))
		scroll.drawsBackground = false
		scroll.hasVerticalScroller = true
		scroll.scrollerStyle = .overlay
		scroll.automaticallyAdjustsContentInsets = false
		scroll.autohidesScrollers = true

		let custom = scroller(frame: .zero)
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
		rootBlur.addSubview(scroll)
	}
}
