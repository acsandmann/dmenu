import CoreGraphics
import Foundation

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
		textPadding: 10, sidePadding: 5),

	.small: .init(
		width: 480, itemH: 36, maxRows: 4, searchH: 45,
		searchFieldHeight: 28, borderRadius: 8, searchFontSize: 18,
		itemFontSize: 13, iconSize: 24, iconPadding: 44,
		textPadding: 12, sidePadding: 6),

	.medium: .init(
		width: 600, itemH: 42, maxRows: 5, searchH: 50,
		searchFieldHeight: 32, borderRadius: 10, searchFontSize: 20,
		itemFontSize: 14, iconSize: 28, iconPadding: 50,
		textPadding: 14, sidePadding: 7),

	.large: .init(
		width: 720, itemH: 48, maxRows: 6, searchH: 57,
		searchFieldHeight: 36, borderRadius: 12, searchFontSize: 24,
		itemFontSize: 16, iconSize: 32, iconPadding: 56,
		textPadding: 16, sidePadding: 8),
]

struct dmenu_config {
	let placeholder: String
	let showIcon: Bool

	let width, itemH, maxRows, searchH,
		searchFieldHeight, borderRadius,
		searchFontSize, itemFontSize,
		iconSize, iconPadding,
		textPadding, sidePadding: CGFloat

	var totalHeight: CGFloat { searchH + itemH * maxRows }

	static func make(from argv: [String] = CommandLine.arguments) -> DMenuConfig? {
		var size: menu_size = .medium
		var showIcon = false
		var placeholderArg: String?
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
			case "-p", "--placeholder":
				guard i + 1 < argv.count else {
					fatalError("'-p/--placeholder' requires a value.")
				}
				placeholderArg = argv[i + 1]
				i += 1

			default:
				fatalError("Unknown argument '\(arg)'. Run with -h for help.")
			}
			i += 1
		}

		let placeholder =
			placeholderArg ?? UserDefaults.standard.string(forKey: "placeholder") ?? "Search"

		let p = presets[size]!

		return dmenu_config(
			placeholder: placeholder, showIcon: showIcon,
			width: p.width, itemH: p.itemH, maxRows: p.maxRows, searchH: p.searchH,
			searchFieldHeight: p.searchFieldHeight, borderRadius: p.borderRadius,
			searchFontSize: p.searchFontSize, itemFontSize: p.itemFontSize,
			iconSize: p.iconSize, iconPadding: p.iconPadding,
			textPadding: p.textPadding, sidePadding: p.sidePadding
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
			  -h , --help              Show this help and exit
			""")
	}
}
