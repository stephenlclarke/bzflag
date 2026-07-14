import BZFlagCore
import Foundation
import Observation

@MainActor
@Observable
final class BZFlagViewModel {
  var match = BZFlagMatch()
  var statusMessage = "Local arena ready. Use Tab to jump over the buildings."
  @ObservationIgnored private var simulationTimer: Timer?

  init() {
    simulationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
      Task { @MainActor in self?.advance() }
    }
  }

  func move(_ distance: Double) {
    let moved = match.move(distance)
    statusMessage = moved ? "Tank moved \(distance > 0 ? "forward" : "backward")." : match.lastEvent
  }

  func turn(_ direction: Double) {
    match.turn(direction)
    statusMessage = direction < 0 ? "Turning left." : "Turning right."
  }

  func jump() {
    _ = match.jump()
    statusMessage = match.lastEvent
  }

  func fire() {
    _ = match.fire()
    statusMessage = match.lastEvent
  }

  func dropFlag() {
    _ = match.dropFlag()
    statusMessage = match.lastEvent
  }

  func reset() {
    match = BZFlagMatch()
    statusMessage = "Local arena reset."
  }

  private func advance() {
    match.step(by: 1.0 / 30.0)
    if !match.projectiles.isEmpty || match.player.altitude > 0 {
      statusMessage = match.lastEvent
    }
  }
}
