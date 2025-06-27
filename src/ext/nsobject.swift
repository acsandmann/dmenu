import Cocoa

extension NSObject {
	@inline(__always)
	func apply(_ body: (Self) -> Void) -> Self {
		body(self)
		return self
	}
}
