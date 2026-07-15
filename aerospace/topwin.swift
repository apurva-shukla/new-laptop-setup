import CoreGraphics
let info = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as! [[String: Any]]
for w in info {
    let layer = w["kCGWindowLayer"] as! Int
    let b = w["kCGWindowBounds"] as! [String: Any]
    print("\(w["kCGWindowNumber"]!) | layer \(layer) | \(w["kCGWindowOwnerName"]!) | \(b["Width"]!)x\(b["Height"]!)")
}
