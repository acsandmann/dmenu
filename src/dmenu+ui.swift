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
		rootBlur.layer?.masksToBounds = false
		window.contentView = rootBlur

		let glowLayer = CALayer()
		glowLayer.frame = rootBlur.bounds.insetBy(dx: -3, dy: -3)
		glowLayer.cornerRadius = borderRadius + 3
		glowLayer.backgroundColor = NSColor.clear.cgColor
		glowLayer.borderWidth = 1.5
		glowLayer.borderColor = NSColor.systemCyan.withAlphaComponent(0.4).cgColor
		glowLayer.shadowColor = NSColor.systemCyan.cgColor
		glowLayer.shadowRadius = 15
		glowLayer.shadowOpacity = 0.6
		glowLayer.shadowOffset = .zero
		rootBlur.layer?.superlayer?.insertSublayer(glowLayer, below: rootBlur.layer)

		let glowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
		glowAnimation.fromValue = 0.3
		glowAnimation.toValue = 0.8
		glowAnimation.duration = 2.0
		glowAnimation.autoreverses = true
		glowAnimation.repeatCount = .infinity
		glowLayer.add(glowAnimation, forKey: "glow")

		let holoGradient = CAGradientLayer()
		holoGradient.frame = rootBlur.bounds
		holoGradient.cornerRadius = borderRadius
		holoGradient.colors = [
			NSColor.systemCyan.withAlphaComponent(0.08).cgColor,
			NSColor.systemPurple.withAlphaComponent(0.06).cgColor,
			NSColor.systemBlue.withAlphaComponent(0.04).cgColor,
			NSColor.systemTeal.withAlphaComponent(0.08).cgColor,
		]
		holoGradient.locations = [0, 0.3, 0.7, 1.0]
		holoGradient.startPoint = CGPoint(x: 0, y: 0)
		holoGradient.endPoint = CGPoint(x: 1, y: 1)
		rootBlur.layer?.addSublayer(holoGradient)

		let gradientAnimation = CABasicAnimation(keyPath: "locations")
		gradientAnimation.fromValue = [0, 0.3, 0.7, 1.0]
		gradientAnimation.toValue = [0.2, 0.5, 0.9, 1.2]
		gradientAnimation.duration = 4.0
		gradientAnimation.autoreverses = true
		gradientAnimation.repeatCount = .infinity
		holoGradient.add(gradientAnimation, forKey: "gradientShift")

		let shadowLayer = CALayer()
		shadowLayer.frame = rootBlur.bounds
		shadowLayer.cornerRadius = borderRadius
		shadowLayer.backgroundColor = NSColor.black.withAlphaComponent(0.3).cgColor
		shadowLayer.shadowColor = NSColor.black.cgColor
		shadowLayer.shadowOpacity = 0.5
		shadowLayer.shadowRadius = 30
		shadowLayer.shadowOffset = CGSize(width: 0, height: -10)
		rootBlur.layer?.superlayer?.insertSublayer(shadowLayer, below: rootBlur.layer)
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

		searchField = searchfield(
			frame: .init(
				x: leadingX,
				y: ySearch,
				width: width - leadingX - config.textPadding,
				height: searchFieldH
			))
		searchField.itemFontSize = config.searchFontSize
		searchField.placeholderString = config.placeholder
		searchField.focusRingType = .none
		searchField.delegate = self
		(searchField.cell as? NSSearchFieldCell)?.font = .systemFont(ofSize: config.searchFontSize)

		searchField.isBordered = false
		searchField.drawsBackground = false
		searchField.wantsLayer = true
		if let cell = searchField.cell as? NSSearchFieldCell {
			cell.searchButtonCell = nil
			cell.cancelButtonCell = nil
		}
		rootBlur.addSubview(searchField)

		let sep = NSView(
			frame: .init(
				x: 0,
				y: height - searchH,
				width: width,
				height: 1
			))
		sep.wantsLayer = true
		sep.layer?.backgroundColor = NSColor.separatorColor.withAlphaComponent(0.07).cgColor
		sep.autoresizingMask = [.width]
		rootBlur.addSubview(sep)

		let scroll = NSScrollView(
			frame: .init(
				x: sidePadding,
				y: 0,
				width: width - sidePadding,
				height: height - searchH
			))
		scroll.drawsBackground = false
		scroll.hasVerticalScroller = true
		scroll.scrollerStyle = .overlay
		scroll.automaticallyAdjustsContentInsets = false
		scroll.autohidesScrollers = false
		scroll.scrollerKnobStyle = .light

		let custom = scroller(frame: .zero)
		custom.padding = sidePadding
		custom.scrollerStyle = .overlay
		scroll.verticalScroller = custom

		tableView = NSTableView(
			frame: scroll.frame)
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

final class searchfield: NSSearchField {
	var itemFontSize: CGFloat!

	override func awakeFromNib() {
		super.awakeFromNib()
		updateStyling()
	}

	override var stringValue: String {
		didSet {
			updateTextStyling()
		}
	}

	override var placeholderString: String? {
		didSet {
			updatePlaceholderStyling()
		}
	}

	override func textDidChange(_ notification: Notification) {
		super.textDidChange(notification)
		applyFieldEditorStyling()
	}

	override func becomeFirstResponder() -> Bool {
		let result = super.becomeFirstResponder()
		if result {
			applyFieldEditorStyling()
		}
		return result
	}

	func updateStyling() {
		updateTextStyling()
		updatePlaceholderStyling()
		applyFieldEditorStyling()
	}

	private func applyFieldEditorStyling() {
		guard let fieldEditor = currentEditor() as? NSTextView,
		      let textStorage = fieldEditor.textStorage
		else { return }

		let fullRange = NSRange(location: 0, length: textStorage.length)
		textStorage.addAttributes(
			[
				NSAttributedString.Key.font: NSFont.monospacedSystemFont(
					ofSize: itemFontSize, weight: .regular
				),
				NSAttributedString.Key.foregroundColor: NSColor.labelColor.withAlphaComponent(0.8),
				NSAttributedString.Key.kern: 0.5,
			], range: fullRange
		)
	}

	private func updateTextStyling() {
		let text = stringValue
		let attr = NSMutableAttributedString(string: text)
		attr.addAttributes(
			[
				.font: NSFont.monospacedSystemFont(ofSize: itemFontSize, weight: .regular),
				.foregroundColor: NSColor.labelColor.withAlphaComponent(0.8),
				.kern: 0.5,
			], range: NSRange(location: 0, length: text.count)
		)
		attributedStringValue = attr
	}

	private func updatePlaceholderStyling() {
		guard let placeholder = placeholderString else { return }
		let attr = NSMutableAttributedString(string: placeholder)
		attr.addAttributes(
			[
				.font: NSFont.monospacedSystemFont(ofSize: itemFontSize, weight: .regular),
				.foregroundColor: NSColor.labelColor.withAlphaComponent(0.8),
				.kern: 0.5,
			], range: NSRange(location: 0, length: placeholder.count)
		)
		placeholderAttributedString = attr
	}
}
