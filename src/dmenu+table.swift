import Cocoa

extension dmenu {

  func numberOfRows(in tableView: NSTableView) -> Int { filteredItems.count }

  func tableView(
    _ tableView: NSTableView,
    viewFor tableColumn: NSTableColumn?,
    row: Int
  ) -> NSView? {
    let item = filteredItems[row]
    let pad: CGFloat = config.sidePadding / 2

    let txt = NSTextField()
    txt.isBordered = false
    txt.drawsBackground = false
    txt.isEditable = false
    txt.lineBreakMode = .byTruncatingTail
    txt.font = .systemFont(ofSize: config.itemFontSize)
    txt.textColor = .labelColor

    let tokens = searchField.stringValue
      .lowercased()
      .split(whereSeparator: \.isWhitespace)
    if !tokens.isEmpty {
      let lowerItem = item.lowercased()
      let attr = NSMutableAttributedString(string: item)

      for tok in tokens {
        var searchStart = lowerItem.startIndex
        while let r = lowerItem.range(of: tok, range: searchStart..<lowerItem.endIndex) {
          attr.addAttribute(
            .underlineStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: NSRange(r, in: item))
          searchStart = r.upperBound
        }
      }
      txt.attributedStringValue = attr
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
      height: textSize.height)
    cont.addSubview(txt)
    return cont
  }

  func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
    dmenu_row()
  }

  func moveSelection(offset: Int) {
    guard !filteredItems.isEmpty else { return }
    let next = max(0, min(tableView.selectedRow + offset, filteredItems.count - 1))
    selectRow(index: next)
  }

  func selectRow(index: Int) {
    guard !filteredItems.isEmpty else { return }
    tableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
    tableView.scrollRowToVisible(index)
  }

  func selectCurrentRow() {
    let r = tableView.selectedRow
    guard r >= 0, r < filteredItems.count else { return }
    print(filteredItems[r])
    fflush(stdout)
    NSApp.terminate(nil)
  }

  @objc func handleClick() { selectCurrentRow() }
}

final class dmenu_row: NSTableRowView {
  override func drawSelection(in dirtyRect: NSRect) {
    guard selectionHighlightStyle != .none else { return }
    let rect = bounds.insetBy(dx: 2, dy: 2)
    let path = NSBezierPath(roundedRect: rect, xRadius: 6, yRadius: 6)
    NSColor.tertiaryLabelColor.withAlphaComponent(0.1).setFill()
    path.fill()
  }

  override func updateTrackingAreas() {
    super.updateTrackingAreas()
    trackingAreas.forEach(removeTrackingArea(_:))
    let opts: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways, .inVisibleRect]
    addTrackingArea(NSTrackingArea(rect: bounds, options: opts, owner: self))
  }

  override func mouseEntered(with event: NSEvent) {
    super.mouseEntered(with: event)
    if !isSelected { needsDisplay = true }
  }

  override func mouseExited(with event: NSEvent) {
    super.mouseExited(with: event)
    needsDisplay = true
  }

  override var isEmphasized: Bool {
    get { false }
    set {}
  }
}
