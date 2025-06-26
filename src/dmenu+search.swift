import Cocoa
import Darwin

extension NSObject {
	@inline(__always)
	func apply(_ body: (Self) -> Void) -> Self {
		body(self)
		return self
	}
}

@inline(__always)
private func memRange(
	haystack: UnsafeRawBufferPointer,
	needle: UnsafeRawBufferPointer,
	from start: Int
) -> (lower: Int, upper: Int)? {
	let hCount = haystack.count
	let nCount = needle.count
	guard nCount > 0, start <= hCount - nCount else { return nil }

	let hayRaw = haystack.baseAddress!
	let needRaw = needle.baseAddress!
	let first = needRaw.load(as: UInt8.self)
	var pRaw = hayRaw.advanced(by: start)
	let lastOk = hayRaw.advanced(by: hCount - nCount)
	let hayTyped = hayRaw.assumingMemoryBound(to: UInt8.self)

	while true {
		let offset = hayTyped.distance(to: pRaw.assumingMemoryBound(to: UInt8.self))
		let remain = hCount - offset
		guard remain > 0 else { return nil }

		guard let foundMut = memchr(pRaw, Int32(first), remain) else { return nil }
		let foundRaw = UnsafeRawPointer(foundMut)
		if foundRaw > lastOk { return nil }

		if memcmp(foundRaw, needRaw, nCount) == 0 {
			let lower = hayTyped.distance(to: foundRaw.assumingMemoryBound(to: UInt8.self))
			return (lower, lower + nCount)
		}
		pRaw = foundRaw.advanced(by: 1)
	}
}

extension dmenu {
	func loadStdin() {
		guard
			let data = try? FileHandle.standardInput.readToEnd(),
			let str = String(data: data, encoding: .utf8)
		else { return }

		allItems = str.split(separator: "\n").map(String.init)
		allItemsLower = allItems.map { $0.lowercased() }
		allItemsBytes = allItemsLower.map { Array($0.utf8) }
		allIndices = Array(allItems.indices)
		filteredItems = allItems
		liveIndices = allIndices

		tableView.reloadData()
		selectRow(index: 0)
	}

	func controlTextDidChange(_: Notification) {
		let tokens = searchField.stringValue
			.lowercased()
			.split(whereSeparator: \.isWhitespace)

		currentTokens = tokens

		guard !tokens.isEmpty else {
			filteredItems = allItems
			liveIndices = allIndices
			lastTokens = []
			tableView.reloadData()
			if !filteredItems.isEmpty { selectRow(index: 0) }
			return
		}

		let searchSpace =
			(tokens.starts(with: lastTokens) && !liveIndices.isEmpty)
				? liveIndices
				: allIndices

		Self.workQ.async {
			let tokenBytes = tokens.map { Array($0.utf8) }

			var best = [(score: Int, idx: Int)]()
			best.reserveCapacity(128)

			for idx in searchSpace {
				guard
					let score = self.matchTokens(
						hayBytes: self.allItemsBytes[idx],
						tokens: tokenBytes
					)
				else { continue }

				best.append((score, idx))

				if best.count > 128 {
					best.sort(by: { $0.score > $1.score })
					best.removeLast(best.count - 128)
				}
			}

			best.sort(by: { $0.score > $1.score })

			let newLive = best.map { $0.idx }
			let newItems = newLive.map { self.allItems[$0] }

			DispatchQueue.main.async {
				self.liveIndices = newLive
				self.filteredItems = newItems
				self.lastTokens = tokens
				self.tableView.reloadData()
				if !newItems.isEmpty { self.selectRow(index: 0) }
			}
		}
	}

	private func matchTokens(
		hayBytes: [UInt8],
		tokens: [[UInt8]]
	) -> Int? {
		var cursor = 0
		var score = 0
		for tb in tokens {
			guard
				let r = hayBytes.withUnsafeBytes({ hPtr in
					tb.withUnsafeBytes { nPtr in
						memRange(
							haystack: hPtr,
							needle: nPtr,
							from: cursor
						)
					}
				})
			else { return nil }

			// contiguous bonus + gap penalty
			score &+= 32 // token matched
			score &+= (r.upper - r.lower) == tb.count ? 16 : 0
			score &-= (r.lower - cursor) * 2 // gap penalty
			cursor = r.upper
		}
		score &-= (hayBytes.count - cursor) // prefer shorter tail after last match
		return score
	}

	func installKeyMonitor() {
		NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] e in
			guard let self = self else { return e }
			switch e.keyCode {
			case 126:
				self.moveSelection(offset: -1)
				return nil
			case 125:
				self.moveSelection(offset: 1)
				return nil
			case 35 where e.modifierFlags.contains(.control):
				self.moveSelection(offset: -1)
				return nil
			case 45 where e.modifierFlags.contains(.control):
				self.moveSelection(offset: 1)
				return nil
			case 36:
				self.selectCurrentRow()
				return nil
			case 8 where e.modifierFlags.contains(.control), 53:
				self.closeWindow()
				return nil
			default: return e
			}
		}
	}
}
