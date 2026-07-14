import SwiftUI

@main
struct BZFlagApp: App {
  @State private var model = BZFlagViewModel()

  var body: some Scene {
    WindowGroup("BZFlag", id: "bzflag") {
      BZFlagContentView(model: model)
    }
    .commands {
      CommandMenu("BZFlag") {
        Button("Drive Forward") { model.move(4) }
          .keyboardShortcut("w")
        Button("Drive Backward") { model.move(-4) }
          .keyboardShortcut("s")
        Button("Turn Left") { model.turn(-1) }
          .keyboardShortcut("a")
        Button("Turn Right") { model.turn(1) }
          .keyboardShortcut("d")
        Divider()
        Button("Fire") { model.fire() }
          .keyboardShortcut(.space, modifiers: [])
        Button("Jump") { model.jump() }
          .keyboardShortcut(.tab, modifiers: [])
        Button("Drop Flag") { model.dropFlag() }
          .keyboardShortcut("e")
        Divider()
        Button("Reset Local Arena") { model.reset() }
          .keyboardShortcut("r")
      }
    }
  }
}
