import Cocoa

final class textfield: NSTextField {
	var itemFontSize: CGFloat!

	override var allowsVibrancy: Bool { false }

	override var stringValue: String {
		didSet { applyBaseAttributes() }
	}

	override var attributedStringValue: NSAttributedString {
		didSet {}
	}

	private func applyBaseAttributes() {
		guard !stringValue.isEmpty else { return }

		let baseFont = NSFont.monospacedSystemFont(ofSize: itemFontSize, weight: .regular)
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

	func highlight(item: String, tokens: [String]) -> NSAttributedString {
		let attr = NSMutableAttributedString(string: item)
		let baseFont = NSFont.monospacedSystemFont(ofSize: itemFontSize, weight: .regular)

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
							ofSize: itemFontSize, weight: .bold
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
}
