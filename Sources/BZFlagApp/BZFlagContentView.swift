import BZFlagCore
import Foundation
import SwiftUI

struct BZFlagContentView: View {
  @Bindable var model: BZFlagViewModel

  var body: some View {
    VStack(spacing: 12) {
      FirstPersonArenaView(match: model.match)
        .frame(minWidth: 720, idealWidth: 900, minHeight: 310, idealHeight: 390)

      HStack(alignment: .top, spacing: 16) {
        RadarView(match: model.match)
          .frame(width: 350, height: 260)

        GroupBox("Tank controls") {
          Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 8) {
            GridRow { key("W"); Button("Drive forward") { model.move(4) } }
            GridRow { key("S"); Button("Drive backward") { model.move(-4) } }
            GridRow { key("A"); Button("Turn left") { model.turn(-1) } }
            GridRow { key("D"); Button("Turn right") { model.turn(1) } }
            GridRow { key("Space"); Button("Fire") { model.fire() } }
            GridRow { key("Tab"); Button("Jump") { model.jump() } }
            GridRow { key("E"); Button("Drop flag") { model.dropFlag() } }
          }
          Divider().padding(.vertical, 4)
          Text("The original client drove with the mouse; these native controls provide deterministic keyboard and toolbar play.")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(minWidth: 250)

        GroupBox("Score and flag") {
          LabeledContent("Wins", value: "\(model.match.player.wins)")
          LabeledContent("Losses", value: "\(model.match.player.losses)")
          LabeledContent("Flag", value: model.match.player.heldFlag?.title ?? "None")
          LabeledContent("Reload", value: String(format: "%.1f s", model.match.reloadRemaining))
          Divider().padding(.vertical, 4)
          Text("Target: \(model.match.opponent.callsign) · \(model.match.opponent.losses) losses")
          Button("Reset Local Arena") { model.reset() }
        }
        .frame(minWidth: 180)
      }

      Text(model.statusMessage)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.secondary)
    }
    .padding()
    .navigationTitle("BZFlag")
  }

  private func key(_ text: String) -> some View {
    Text(text)
      .font(.system(.body, design: .monospaced).weight(.semibold))
  }
}
