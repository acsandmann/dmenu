import Cocoa

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
