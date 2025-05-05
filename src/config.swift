import Cocoa

enum menuSize {
  case extraSmall, small, medium, large
}

struct dmenuConfig {
  let placeholder: String
  let showIcon: Bool

  let width: CGFloat
  let itemH: CGFloat
  let maxRows: CGFloat
  let searchH: CGFloat
  let searchFieldHeight: CGFloat
  let borderRadius: CGFloat
  let searchFontSize: CGFloat
  let itemFontSize: CGFloat
  let iconSize: CGFloat
  let iconPadding: CGFloat
  let textPadding: CGFloat
  let sidePadding: CGFloat

  var totalHeight: CGFloat { searchH + itemH * maxRows }

  static func build() -> dmenuConfig {
    var size: menuSize = .medium
    let argv = ProcessInfo.processInfo.arguments

    if argv.contains("-xs") { size = .extraSmall }
    if argv.contains("-s") { size = .small }
    if argv.contains("-m") { size = .medium }
    if argv.contains("-l") { size = .large }

    let placeholder =
      UserDefaults.standard.string(forKey: "p")
      ?? UserDefaults.standard.string(forKey: "placeholder")
      ?? "Search"

    let showIcon = argv.contains("-i") || argv.contains("--icon")

    switch size {
    case .extraSmall:
      return dmenuConfig(
        placeholder: placeholder, showIcon: showIcon,
        width: 400, itemH: 30, maxRows: 4, searchH: 40,
        searchFieldHeight: 24, borderRadius: 6, searchFontSize: 16,
        itemFontSize: 12, iconSize: 20, iconPadding: 38, textPadding: 10, sidePadding: 5
      )
    case .small:
      return dmenuConfig(
        placeholder: placeholder, showIcon: showIcon,
        width: 480, itemH: 36, maxRows: 4, searchH: 45,
        searchFieldHeight: 28, borderRadius: 8, searchFontSize: 18,
        itemFontSize: 13, iconSize: 24, iconPadding: 44, textPadding: 12, sidePadding: 6
      )
    case .medium:
      return dmenuConfig(
        placeholder: placeholder, showIcon: showIcon,
        width: 600, itemH: 42, maxRows: 5, searchH: 50,
        searchFieldHeight: 32, borderRadius: 10, searchFontSize: 20,
        itemFontSize: 14, iconSize: 28, iconPadding: 50, textPadding: 14, sidePadding: 7
      )
    case .large:
      return dmenuConfig(
        placeholder: placeholder, showIcon: showIcon,
        width: 720, itemH: 48, maxRows: 6, searchH: 57,
        searchFieldHeight: 36, borderRadius: 12, searchFontSize: 24,
        itemFontSize: 16, iconSize: 32, iconPadding: 56, textPadding: 16, sidePadding: 8
      )
    }
  }
}
