import Cocoa

final class dmenu: NSObject,
	NSApplicationDelegate,
	NSTableViewDataSource,
	NSTableViewDelegate,
	NSSearchFieldDelegate
{
	var window: NSWindow!
	var tableView: NSTableView!
	var searchField: NSSearchField!

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
		window.makeFirstResponder(searchField)
		NSApp.activate(ignoringOtherApps: true)
		installKeyMonitor()
	}

	func applicationDidResignActive(_: Notification) {
		NSApp.terminate(nil)
	}
}
