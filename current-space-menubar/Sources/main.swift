import AppKit
import Foundation

final class Logger {
    private let logURL = URL(fileURLWithPath: "/tmp/current-space-menu.log")

    func log(_ message: String) {
        let line = "\(timestamp()) \(message)\n"

        guard let data = line.data(using: .utf8) else {
            return
        }

        if FileManager.default.fileExists(atPath: logURL.path) {
            if let handle = try? FileHandle(forWritingTo: logURL) {
                defer { try? handle.close() }
                _ = try? handle.seekToEnd()
                try? handle.write(contentsOf: data)
            }
        } else {
            try? data.write(to: logURL)
        }
    }

    private func timestamp() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: Date())
    }
}

struct Space: Decodable {
    let index: Int
    let label: String?
    let windows: [Int]
    let hasFocus: Bool
    let isVisible: Bool

    enum CodingKeys: String, CodingKey {
        case index
        case label
        case windows
        case hasFocus = "has-focus"
        case isVisible = "is-visible"
    }
}

struct Window: Decodable {
    let app: String
    let space: Int
    let isHidden: Bool
    let isMinimized: Bool

    enum CodingKeys: String, CodingKey {
        case app
        case space
        case isHidden = "is-hidden"
        case isMinimized = "is-minimized"
    }
}

enum YabaiError: LocalizedError {
    case missingExecutable
    case commandFailed(String)
    case invalidOutput

    var errorDescription: String? {
        switch self {
        case .missingExecutable:
            return "Unable to find the yabai executable."
        case .commandFailed(let output):
            return output.isEmpty ? "The yabai command failed." : output
        case .invalidOutput:
            return "The yabai command returned invalid JSON."
        }
    }
}

final class YabaiClient {
    private let fileManager = FileManager.default
    private let decoder = JSONDecoder()
    private let executableCandidates: [String] = [
        "/opt/homebrew/bin/yabai",
        "/usr/local/bin/yabai",
        "/usr/bin/yabai",
    ]

    private func executablePath() -> String? {
        for candidate in executableCandidates where fileManager.isExecutableFile(atPath: candidate) {
            return candidate
        }

        if let pathValue = ProcessInfo.processInfo.environment["PATH"] {
            for directory in pathValue.split(separator: ":") {
                let candidate = String(directory) + "/yabai"
                if fileManager.isExecutableFile(atPath: candidate) {
                    return candidate
                }
            }
        }

        return nil
    }

    private func run(_ arguments: [String]) throws -> String {
        guard let executable = executablePath() else {
            throw YabaiError.missingExecutable
        }

        let process = Process()
        let stdout = Pipe()
        let stderr = Pipe()

        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = stdout
        process.standardError = stderr

        try process.run()
        process.waitUntilExit()

        let outputData = stdout.fileHandleForReading.readDataToEndOfFile()
        let errorData = stderr.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let errorOutput = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard process.terminationStatus == 0 else {
            throw YabaiError.commandFailed(errorOutput.isEmpty ? output : errorOutput)
        }

        return output
    }

    func fetchSpaces() throws -> [Space] {
        let output = try run(["-m", "query", "--spaces"])
        guard let data = output.data(using: .utf8) else {
            throw YabaiError.invalidOutput
        }

        do {
            return try decoder.decode([Space].self, from: data)
        } catch {
            throw YabaiError.invalidOutput
        }
    }

    func fetchCurrentSpace() throws -> Space {
        let output = try run(["-m", "query", "--spaces", "--space"])
        guard let data = output.data(using: .utf8) else {
            throw YabaiError.invalidOutput
        }

        do {
            return try decoder.decode(Space.self, from: data)
        } catch {
            throw YabaiError.invalidOutput
        }
    }

    func fetchWindows() throws -> [Window] {
        let output = try run(["-m", "query", "--windows"])
        guard let data = output.data(using: .utf8) else {
            throw YabaiError.invalidOutput
        }

        do {
            return try decoder.decode([Window].self, from: data)
        } catch {
            throw YabaiError.invalidOutput
        }
    }

    func focusSpace(_ index: Int) throws {
        _ = try run(["-m", "space", "--focus", String(index)])
    }
}

final class SpaceMenuController: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let client = YabaiClient()
    private let logger = Logger()
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()
    private let hiddenSummaryApps: Set<String> = [
        "Claude",
        "CurrentSpaceMenu",
        "Granola",
    ]
    private var refreshTimer: Timer?
    private var spaces: [Space] = []
    private var appsBySpace: [Int: [String]] = [:]
    private var currentSpaceIndex: Int?
    private var lastError: String?
    private var lastLoggedState: String?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        logger.log("application did finish launching")

        menu.delegate = self
        statusItem.menu = menu

        if let button = statusItem.button {
            button.font = NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
            button.lineBreakMode = .byTruncatingTail
        }

        refresh()

        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.refresh()
        }
        RunLoop.main.add(refreshTimer!, forMode: .common)
    }

    func applicationWillTerminate(_ notification: Notification) {
        refreshTimer?.invalidate()
    }

    func menuWillOpen(_ menu: NSMenu) {
        refresh()
        rebuildMenu()
    }

    @objc
    private func focusSpace(_ sender: NSMenuItem) {
        guard let index = sender.representedObject as? Int else {
            return
        }

        do {
            try client.focusSpace(index)
            refresh()
        } catch {
            lastError = error.localizedDescription
            rebuildMenu()
        }
    }

    @objc
    private func refreshFromMenu() {
        refresh()
        rebuildMenu()
    }

    @objc
    private func quit() {
        NSApp.terminate(nil)
    }

    private func refresh() {
        do {
            spaces = try client.fetchSpaces().sorted { $0.index < $1.index }
            currentSpaceIndex = try client.fetchCurrentSpace().index
            appsBySpace = groupedApps(from: try client.fetchWindows())
            lastError = nil
            logCurrentStateIfNeeded()
            updateStatusTitle()
        } catch {
            spaces = []
            appsBySpace = [:]
            currentSpaceIndex = nil
            lastError = error.localizedDescription
            logCurrentStateIfNeeded()
            updateStatusTitle()
        }
    }

    private func updateStatusTitle() {
        guard let button = statusItem.button else {
            return
        }

        let title: String
        let toolTip: String

        if currentSpace != nil, !spaces.isEmpty {
            title = occupancyStrip()
            toolTip = occupancyTooltip()
        } else {
            title = "--"
            toolTip = lastError ?? "No focused space detected."
        }

        let style = NSMutableParagraphStyle()
        style.alignment = .center

        let font = NSFont.monospacedSystemFont(ofSize: 13, weight: .semibold)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: style,
        ]

        let templateTitle = occupancyTemplateStrip()
        let templateWidth = (templateTitle as NSString).size(withAttributes: attributes).width
        statusItem.length = max(templateWidth + 28, 92)
        button.attributedTitle = NSAttributedString(string: title, attributes: attributes)
        button.toolTip = toolTip
    }

    private var currentSpace: Space? {
        if let currentSpaceIndex {
            return spaces.first(where: { $0.index == currentSpaceIndex })
        }

        return spaces.first(where: { $0.hasFocus }) ?? spaces.first(where: { $0.isVisible })
    }

    private func logCurrentStateIfNeeded() {
        let state: String

        if let current = currentSpace {
            if let label = normalizedLabel(for: current) {
                state = "space=\(current.index) label=\(label)"
            } else {
                state = "space=\(current.index)"
            }
        } else if let lastError {
            state = "error=\(lastError)"
        } else {
            state = "error=unknown"
        }

        guard state != lastLoggedState else {
            return
        }

        lastLoggedState = state
        logger.log(state)
    }

    private func normalizedLabel(for space: Space) -> String? {
        guard let label = space.label?.trimmingCharacters(in: .whitespacesAndNewlines), !label.isEmpty else {
            return nil
        }

        return label
    }

    private func groupedApps(from windows: [Window]) -> [Int: [String]] {
        var grouped: [Int: [String]] = [:]

        for window in windows where !window.isHidden && !window.isMinimized {
            let appName = normalizedAppName(window.app)
            var apps = grouped[window.space, default: []]
            if !apps.contains(appName) {
                apps.append(appName)
            }
            grouped[window.space] = apps
        }

        for (space, apps) in grouped {
            grouped[space] = apps.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        }

        return grouped
    }

    private func normalizedAppName(_ app: String) -> String {
        let cleaned = app
            .replacingOccurrences(of: "\u{200E}", with: "")
            .replacingOccurrences(of: "\u{200F}", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        switch cleaned {
        case "Google Chrome":
            return "Chrome"
        default:
            return cleaned
        }
    }

    private func occupancyGlyph(for space: Space) -> String {
        if space.index == currentSpaceIndex {
            return "◆"
        }

        return space.windows.isEmpty ? "·" : "•"
    }

    private func occupancyStrip() -> String {
        spaces.map(occupancyGlyph(for:)).joined(separator: " ")
    }

    private func occupancyTemplateStrip() -> String {
        guard !spaces.isEmpty else {
            return "• ◆ •"
        }

        return spaces.enumerated().map { index, _ in
            index == max(spaces.count / 2, 0) ? "◆" : "•"
        }.joined(separator: " ")
    }

    private func occupancyTooltip() -> String {
        guard let current = currentSpace else {
            return lastError ?? "No focused space detected."
        }

        var lines: [String] = [tooltipLine(for: current)]

        for space in spaces where space.index != current.index {
            lines.append(tooltipLine(for: space))
        }

        return lines.joined(separator: "\n")
    }

    private func tooltipLine(for space: Space) -> String {
        let glyph = menuGlyph(for: space)
        let details = spaceDetails(for: space)
        return "\(glyph)  \(space.index) \(details)"
    }

    private func spaceDetails(for space: Space) -> String {
        let visibleApps = (appsBySpace[space.index] ?? []).filter { !hiddenSummaryApps.contains($0) }
        let apps = visibleApps.isEmpty ? (appsBySpace[space.index] ?? []) : visibleApps

        guard !apps.isEmpty else {
            return "Empty"
        }

        if apps.count <= 2 {
            return apps.joined(separator: ", ")
        }

        let leadingApps = apps.prefix(2).joined(separator: ", ")
        return "\(leadingApps) +\(apps.count - 2)"
    }

    private func menuGlyph(for space: Space) -> String {
        if space.index == currentSpaceIndex {
            return "◆"
        }

        return space.windows.isEmpty ? "·" : "•"
    }

    private func rebuildMenu() {
        menu.removeAllItems()

        if let current = currentSpace {
            let orderedSpaces = [current] + spaces.filter { $0.index != current.index }

            for space in orderedSpaces {
                let item = NSMenuItem(title: tooltipLine(for: space), action: #selector(focusSpace(_:)), keyEquivalent: "")
                item.target = self
                item.representedObject = space.index
                menu.addItem(item)
            }
        } else {
            let errorTitle = lastError ?? "Unable to read the current space."
            let errorItem = NSMenuItem(title: errorTitle, action: nil, keyEquivalent: "")
            errorItem.isEnabled = false
            menu.addItem(errorItem)
        }

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Refresh", action: #selector(refreshFromMenu), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
    }
}

let app = NSApplication.shared
let delegate = SpaceMenuController()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
