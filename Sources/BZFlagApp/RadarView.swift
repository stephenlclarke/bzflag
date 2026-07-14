import BZFlagCore
import SwiftUI

struct RadarView: View {
  let match: BZFlagMatch

  var body: some View {
    Canvas { context, size in
      context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black))
      let scale = min(size.width / match.arena.width, size.height / match.arena.height)
      let origin = CGPoint(
        x: (size.width - CGFloat(match.arena.width) * scale) / 2,
        y: (size.height - CGFloat(match.arena.height) * scale) / 2
      )
      for obstacle in match.arena.obstacles {
        let rect = CGRect(
          x: origin.x + CGFloat(obstacle.center.x - obstacle.halfSize.x) * scale,
          y: origin.y + CGFloat(obstacle.center.y - obstacle.halfSize.y) * scale,
          width: CGFloat(obstacle.halfSize.x * 2) * scale,
          height: CGFloat(obstacle.halfSize.y * 2) * scale
        )
        context.fill(Path(rect), with: .color(.green.opacity(0.5)))
      }
      for flag in match.flags {
        let point = position(flag.position, origin: origin, scale: scale)
        context.fill(Path(ellipseIn: CGRect(x: point.x - 4, y: point.y - 4, width: 8, height: 8)), with: .color(color(for: flag.kind)))
      }
      drawTank(match.player, color: .cyan, in: &context, origin: origin, scale: scale)
      drawTank(match.opponent, color: .red, in: &context, origin: origin, scale: scale)
      for projectile in match.projectiles {
        let point = position(projectile.position, origin: origin, scale: scale)
        context.fill(Path(ellipseIn: CGRect(x: point.x - 2, y: point.y - 2, width: 4, height: 4)), with: .color(.yellow))
      }
    }
    .overlay(alignment: .topLeading) {
      Text("RADAR")
        .font(.caption.weight(.bold))
        .foregroundStyle(.green)
        .padding(8)
    }
    .background(.black, in: RoundedRectangle(cornerRadius: 10))
    .accessibilityLabel("BZFlag top-down radar")
  }

  private func drawTank(_ tank: Tank, color: Color, in context: inout GraphicsContext, origin: CGPoint, scale: CGFloat) {
    let point = position(tank.position, origin: origin, scale: scale)
    let radius = max(4, CGFloat(Tank.radius) * scale)
    context.fill(Path(ellipseIn: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)), with: .color(color))
    let heading = CGPoint(x: CGFloat(cos(tank.heading)) * radius, y: CGFloat(sin(tank.heading)) * radius)
    var barrel = Path()
    barrel.move(to: point)
    barrel.addLine(to: CGPoint(x: point.x + heading.x, y: point.y + heading.y))
    context.stroke(barrel, with: .color(.white), lineWidth: 2)
  }

  private func position(_ point: Vector2, origin: CGPoint, scale: CGFloat) -> CGPoint {
    CGPoint(x: origin.x + CGFloat(point.x) * scale, y: origin.y + CGFloat(point.y) * scale)
  }

  private func color(for kind: FlagKind) -> Color {
    switch kind {
    case .jumping: .yellow
    case .quickTurn: .purple
    case .ricochet: .orange
    }
  }
}
