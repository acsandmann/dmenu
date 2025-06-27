import Cocoa

final class textfield: NSTextField {
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
