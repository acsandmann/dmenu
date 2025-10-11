import Cocoa
import Foundation

extension NSColor {
	convenience init?(hex: String) {
		var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
		hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

		var rgb: UInt64 = 0

		var r: CGFloat = 0.0
		var g: CGFloat = 0.0
		var b: CGFloat = 0.0
		var a: CGFloat = 1.0

		let length = hexSanitized.count

		guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

		if length == 6 {
			r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
			g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
			b = CGFloat(rgb & 0x0000FF) / 255.0
		} else if length == 8 {
			r = CGFloat((rgb & 0xFF00_0000) >> 24) / 255.0
			g = CGFloat((rgb & 0x00FF_0000) >> 16) / 255.0
			b = CGFloat((rgb & 0x0000_FF00) >> 8) / 255.0
			a = CGFloat(rgb & 0x0000_00FF) / 255.0
		} else {
			return nil
		}

		self.init(red: r, green: g, blue: b, alpha: a)
	}
}

extension NSFont {
	static func preferred(named name: String?, size: CGFloat, weight: NSFont.Weight) -> NSFont {
		if let name = name, let font = NSFont(name: name, size: size) {
			return font
		} else {
			return NSFont.monospacedSystemFont(ofSize: size, weight: weight)
		}
	}
}

enum menu_size: String {
	case extraSmall = "xs"
	case small = "s"
	case medium = "m"
	case large = "l"
}

private struct size_preset {
	let width, itemH, maxRows, searchH,
		searchFieldHeight, borderRadius,
		searchFontSize, itemFontSize,
		iconSize, iconPadding,
		textPadding, sidePadding: CGFloat
}

private let presets: [menu_size: size_preset] = [
	.extraSmall: .init(
		width: 400, itemH: 30, maxRows: 4, searchH: 40,
		searchFieldHeight: 24, borderRadius: 6, searchFontSize: 16,
		itemFontSize: 12, iconSize: 20, iconPadding: 38,
		textPadding: 10, sidePadding: 5
	),

	.small: .init(
		width: 480, itemH: 36, maxRows: 4, searchH: 45,
		searchFieldHeight: 28, borderRadius: 8, searchFontSize: 18,
		itemFontSize: 13, iconSize: 24, iconPadding: 44,
		textPadding: 12, sidePadding: 6
	),

	.medium: .init(
		width: 600, itemH: 42, maxRows: 5, searchH: 50,
		searchFieldHeight: 32, borderRadius: 10, searchFontSize: 20,
		itemFontSize: 14, iconSize: 28, iconPadding: 50,
		textPadding: 14, sidePadding: 7
	),

	.large: .init(
		width: 720, itemH: 48, maxRows: 6, searchH: 57,
		searchFieldHeight: 36, borderRadius: 12, searchFontSize: 24,
		itemFontSize: 16, iconSize: 32, iconPadding: 56,
		textPadding: 16, sidePadding: 8
	),
]

struct color_scheme {
	let background: NSColor
	let text: NSColor
	let highlight: NSColor
}

private let default_colors = color_scheme(
	background: .black.withAlphaComponent(0.3),
	text: NSColor.labelColor.withAlphaComponent(0.8),
	highlight: NSColor.controlAccentColor
)

struct dmenu_config {
	let placeholder: String
	let showIcon: Bool
	let lock: Bool

	let width, itemH, maxRows, searchH,
		searchFieldHeight, borderRadius,
		searchFontSize, itemFontSize,
		iconSize, iconPadding,
		textPadding, sidePadding: CGFloat

	let colors: color_scheme

	let fontName: String?

	var totalHeight: CGFloat { searchH + itemH * maxRows }

	static func make(from argv: [String] = CommandLine.arguments) -> dmenu_config? {
		var size: menu_size = .medium
		var showIcon = false
		var lock = false
		var placeholderArg: String?
		var bgColorArg: String?
		var textColorArg: String?
		var highlightColorArg: String?
		var fontName: String?
		var i = 1

		while i < argv.count {
			let arg = argv[i]

			switch arg {
			case "-h", "--help":
				print_help()
				return nil
			case "-xs", "--extra-small": size = .extraSmall
			case "-s", "--small": size = .small
			case "-m", "--medium": size = .medium
			case "-l", "--large": size = .large
			case _ where arg.hasPrefix("--size="):
				let raw = String(arg.dropFirst("--size=".count))
				size = menu_size(rawValue: raw) ?? .medium
			case "-i", "--icon": showIcon = true
			case "--lock": lock = true
			case "--font":
				if i + 1 < argv.count, !argv[i + 1].starts(with: "-") {
					fontName = argv[i + 1]
					i += 1
				} else {
					fontName = nil
				}
			case "-p", "--placeholder":
				guard i + 1 < argv.count else {
					fatalError("'-p/--placeholder' requires a value.")
				}
				placeholderArg = argv[i + 1]
				i += 1
			case "--bg-color":
				guard i + 1 < argv.count else {
					fatalError("'--bg-color' requires a hex value.")
				}
				bgColorArg = argv[i + 1]
				i += 1
			case "--text-color":
				guard i + 1 < argv.count else {
					fatalError("'--text-color' requires a hex value.")
				}
				textColorArg = argv[i + 1]
				i += 1
			case "--highlight-color":
				guard i + 1 < argv.count else {
					fatalError("'--highlight-color' requires a hex value.")
				}
				highlightColorArg = argv[i + 1]
				i += 1
			default:
				fatalError("Unknown argument '\(arg)'. Run with -h for help.")
			}
			i += 1
		}

		let placeholder =
			placeholderArg ?? UserDefaults.standard.string(forKey: "placeholder") ?? "Search"

		let p = presets[size]!
		let colors = color_scheme(
			background: {
				if let hex = bgColorArg {
					guard let color = NSColor(hex: hex) else {
						fatalError(
							"Invalid hex color format for --bg-color: '\(hex)'. Use '#RRGGBB' or '#RRGGBBAA'."
						)
					}
					return color
				}
				return default_colors.background
			}(),
			text: {
				if let hex = textColorArg {
					guard let color = NSColor(hex: hex) else {
						fatalError(
							"Invalid hex color format for --text-color: '\(hex)'. Use '#RRGGBB' or '#RRGGBBAA'."
						)
					}
					return color
				}
				return default_colors.text
			}(),
			highlight: {
				if let hex = highlightColorArg {
					guard let color = NSColor(hex: hex) else {
						fatalError(
							"Invalid hex color format for --highlight-color: '\(hex)'. Use '#RRGGBB' or '#RRGGBBAA'."
						)
					}
					return color
				}
				return default_colors.highlight
			}()
		)

		return dmenu_config(
			placeholder: placeholder, showIcon: showIcon, lock: lock,
			width: p.width, itemH: p.itemH, maxRows: p.maxRows, searchH: p.searchH,
			searchFieldHeight: p.searchFieldHeight, borderRadius: p.borderRadius,
			searchFontSize: p.searchFontSize, itemFontSize: p.itemFontSize,
			iconSize: p.iconSize, iconPadding: p.iconPadding,
			textPadding: p.textPadding, sidePadding: p.sidePadding,
			colors: colors, fontName: fontName
		)
	}

	private static func print_help() {
		print(
			"""
			dmenu - minimalist launcher
			Usage: dmenu [options]

			SIZE (mutually exclusive, default --medium)
			  -xs, --extra-small       400 px wide
			  -s , --small             480 px
			  -m , --medium            600 px
			  -l , --large             720 px
			  --size=xs|s|m|l          Alternate form

			OTHER
			  -i , --icon              Show icon column
			  -p , --placeholder TEXT  Custom search-field placeholder
			       --lock              Display-only mode (disable search and selection)
				   --font              Set the font name (default is system monospace font)
			       --bg-color HEX      Set background tint ('#RRGGBBAA' or '#RRGGBB')
			       --text-color HEX    Set item text color
			       --highlight-color HEX Set item highlight color
			  -h , --help              Show this help and exit
			""")
	}
}
