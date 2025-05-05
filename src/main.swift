import Cocoa

let app = NSApplication.shared
let delegate = dmenu()
app.delegate = delegate
app.run()
