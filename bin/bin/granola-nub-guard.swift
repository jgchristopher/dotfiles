// granola-nub-guard — hide sketchybar while Granola's meeting-start banner is up.
//
// Granola 7.452.0's banner (a layer-1000+ window at the top of the display)
// flickers and becomes unclickable when it overlaps sketchybar's bar. Hiding
// the bar for the banner's lifetime (~4s at meeting start) fixes both.
// See memory note granola-nub-flicker for the full diagnosis.
//
// Compiled by `install.sh granola-nub-guard` into
// ~/.local/state/granola-nub-guard/ and run under launchd KeepAlive
// (com.jc.granola-nub-guard).
//
// Test hook: if the file named by $NUB_GUARD_FAKE_BANNER exists, a banner is
// considered present. Lets the hide/restore path be exercised without a meeting.

import CoreGraphics
import Foundation

let sketchybarPath = ["/opt/homebrew/bin/sketchybar", "/usr/local/bin/sketchybar"]
    .first { FileManager.default.isExecutableFile(atPath: $0) }

func log(_ msg: String) {
    let fmt = DateFormatter()
    fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
    print("[\(fmt.string(from: Date()))] \(msg)")
    fflush(stdout)
}

func sketchybar(_ args: [String]) -> String? {
    guard let path = sketchybarPath else { return nil }
    let p = Process()
    p.executableURL = URL(fileURLWithPath: path)
    p.arguments = args
    let pipe = Pipe()
    p.standardOutput = pipe
    p.standardError = Pipe()
    do {
        try p.run()
        p.waitUntilExit()
        guard p.terminationStatus == 0 else { return nil }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    } catch {
        return nil
    }
}

func barHidden() -> Bool? {
    guard let out = sketchybar(["--query", "bar"]) else { return nil }
    return out.contains("\"hidden\": \"on\"")
}

// (granola has any windows, banner present)
func granolaState() -> (running: Bool, banner: Bool) {
    if let fake = ProcessInfo.processInfo.environment["NUB_GUARD_FAKE_BANNER"],
       FileManager.default.fileExists(atPath: fake) {
        return (true, true)
    }
    guard let info = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID)
        as? [[String: Any]] else { return (false, false) }
    var running = false
    for w in info {
        guard (w["kCGWindowOwnerName"] as? String) == "Granola" else { continue }
        running = true
        if let layer = w["kCGWindowLayer"] as? Int, layer >= 1000 {
            return (true, true)
        }
    }
    return (running, false)
}

var weHid = false
var absentPolls = 0

log("granola-nub-guard started (sketchybar: \(sketchybarPath ?? "NOT FOUND"))")

while true {
    let (running, banner) = granolaState()

    if banner {
        absentPolls = 0
        // Only take ownership if the bar is currently visible — a bar the
        // user hid manually stays hidden after the banner goes away.
        if !weHid, barHidden() == false {
            if sketchybar(["--bar", "hidden=on"]) != nil {
                weHid = true
                log("banner detected — bar hidden")
            }
        }
    } else if weHid {
        // Restore only after two consecutive banner-free polls so a banner
        // that flaps during Granola's placement dance doesn't bounce the bar.
        absentPolls += 1
        if absentPolls >= 2 {
            if sketchybar(["--bar", "hidden=off"]) != nil {
                weHid = false
                log("banner gone — bar restored")
            }
        }
    }

    // Poll gently when Granola is idle; tightly while a banner could appear.
    Thread.sleep(forTimeInterval: running ? 0.5 : 3.0)
}
