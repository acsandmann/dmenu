import Cocoa

final class dmenu: NSObject,
	NSApplicationDelegate,
	NSTableViewDataSource,
	NSTableViewDelegate,
	NSSearchFieldDelegate
{
	var window: NSWindow!
	var tableView: NSTableView!
	var searchField: searchfield!

	var allItems: [String] = []
	var allItemsBytes = [[UInt8]]()
	var allItemsLower: [String] = []
	var filteredItems: [String] = []
	var allIndices = [Int]()
	var liveIndices = [Int]()
	var lastTokens = [Substring]()
	var currentTokens: [Substring] = []

	var config: dmenu_config

	static let workQ = DispatchQueue(
		label: "search‑score‑q",
		qos: .userInitiated
	)

	override init() {
		config = dmenu_config.make()!
		super.init()
	}

	func applicationDidFinishLaunching(_: Notification) {
		buildUI()
		loadStdin()
		if let searchField = searchField {
			window.makeFirstResponder(searchField)
		}
		NSApp.activate(ignoringOtherApps: true)
		installKeyMonitor()
	}

	func applicationDidResignActive(_: Notification) {
		closeWindow()
	}

	func closeWindow() {
		NSAnimationContext.runAnimationGroup({ context in
			context.duration = 0.1
			context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

			self.window.animator().alphaValue = 0

			let currentFrame = self.window.frame
			let scaleFactor: CGFloat = 0.8
			let newWidth = currentFrame.width * scaleFactor
			let newHeight = currentFrame.height * scaleFactor
			let offsetX = (currentFrame.width - newWidth) / 2
			let offsetY = (currentFrame.height - newHeight) / 2

			let shrunkFrame = NSRect(
				x: currentFrame.origin.x + offsetX,
				y: currentFrame.origin.y + offsetY,
				width: newWidth,
				height: newHeight
			)

			self.window.animator().setFrame(shrunkFrame, display: true)

			if let contentView = self.window.contentView {
				contentView.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
				contentView.wantsLayer = true
				contentView.layer?.transform = CATransform3DMakeRotation(0.1, 0, 0, 1)
			}
		}) {
			NSApp.terminate(nil)
		}
	}
}
