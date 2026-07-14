import BZFlagCore
import SwiftUI

struct FirstPersonArenaView: View {
  let match: BZFlagMatch

  var body: some View {
    Canvas { context, size in
      let horizon = size.height * 0.42 + CGFloat(match.player.altitude * 2.5)
      drawBackdrop(in: &context, size: size, horizon: horizon)
      drawObstacles(in: &context, size: size, horizon: horizon)
      drawOpponent(in: &context, size: size, horizon: horizon)
      drawProjectiles(in: &context, size: size, horizon: horizon)
    }
    .overlay(alignment: .topLeading) {
      Text("FORWARD VIEW")
        .font(.caption.weight(.bold))
        .foregroundStyle(.green)
        .padding(8)
    }
    .overlay(alignment: .bottomTrailing) {
      Text("ALT \(match.player.altitude, format: .number.precision(.fractionLength(1))) m")
        .font(.caption.monospacedDigit())
        .foregroundStyle(.green)
        .padding(8)
    }
    .background(.black, in: RoundedRectangle(cornerRadius: 10))
    .accessibilityLabel("BZFlag first-person tank view")
  }

  private func drawBackdrop(in context: inout GraphicsContext, size: CGSize, horizon: CGFloat) {
    context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black))
    context.fill(Path(CGRect(x: 0, y: horizon, width: size.width, height: size.height - horizon)), with: .color(.green.opacity(0.16)))
    var line = Path()
    line.move(to: CGPoint(x: 0, y: horizon))
    line.addLine(to: CGPoint(x: size.width, y: horizon))
    context.stroke(line, with: .color(.green), lineWidth: 1)
  }

  private func drawObstacles(in context: inout GraphicsContext, size: CGSize, horizon: CGFloat) {
    for obstacle in match.arena.obstacles {
      guard let projection = project(obstacle.center, in: size), projection.distance > 2 else { continue }
      let width = min(size.width * 0.8, CGFloat(obstacle.halfSize.x * 150 / projection.distance))
      let height = min(size.height * 0.9, CGFloat(obstacle.height * 95 / projection.distance))
      let bottom = horizon + CGFloat(42 / projection.distance) - CGFloat(match.player.altitude * 4)
      let rect = CGRect(x: projection.x - width / 2, y: bottom - height, width: width, height: height)
      context.fill(Path(rect), with: .color(.green.opacity(0.45)))
      context.stroke(Path(rect), with: .color(.green), lineWidth: 1.5)
    }
  }

  private func drawOpponent(in context: inout GraphicsContext, size: CGSize, horizon: CGFloat) {
    guard let projection = project(match.opponent.position, in: size) else { return }
    let radius = min(20, max(4, CGFloat(180 / projection.distance)))
    let center = CGPoint(x: projection.x, y: horizon + CGFloat(30 / projection.distance))
    var tank = Path()
    tank.move(to: CGPoint(x: center.x, y: center.y - radius))
    tank.addLine(to: CGPoint(x: center.x - radius, y: center.y + radius))
    tank.addLine(to: CGPoint(x: center.x + radius, y: center.y + radius))
    tank.closeSubpath()
    context.fill(tank, with: .color(.red))
  }

  private func drawProjectiles(in context: inout GraphicsContext, size: CGSize, horizon: CGFloat) {
    for projectile in match.projectiles {
      guard let projection = project(projectile.position, in: size) else { continue }
      let point = CGPoint(x: projection.x, y: horizon + CGFloat(20 / projection.distance))
      context.fill(Path(ellipseIn: CGRect(x: point.x - 3, y: point.y - 3, width: 6, height: 6)), with: .color(.yellow))
    }
  }

  private func project(_ point: Vector2, in size: CGSize) -> (x: CGFloat, distance: Double)? {
    let relative = point - match.player.position
    let forward = match.player.direction
    let side = Vector2(x: -forward.y, y: forward.x)
    let distance = relative.dot(forward)
    guard distance > 1 else { return nil }
    let angle = atan2(relative.dot(side), distance)
    let fieldOfView = Double.pi * 0.8
    guard abs(angle) < fieldOfView / 2 else { return nil }
    let x = size.width * (0.5 + CGFloat(angle / fieldOfView))
    return (x, distance)
  }
}
