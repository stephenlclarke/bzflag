import Foundation

public struct Vector2: Codable, Hashable, Sendable {
  public var x: Double
  public var y: Double

  public init(x: Double, y: Double) {
    self.x = x
    self.y = y
  }

  public var lengthSquared: Double { x * x + y * y }
  public var length: Double { lengthSquared.squareRoot() }

  public func distance(to other: Vector2) -> Double {
    (self - other).length
  }

  public func normalized() -> Vector2 {
    guard length > 0 else { return Vector2(x: 0, y: 0) }
    return self * (1 / length)
  }

  public static func + (lhs: Vector2, rhs: Vector2) -> Vector2 {
    Vector2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
  }

  public static func - (lhs: Vector2, rhs: Vector2) -> Vector2 {
    Vector2(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
  }

  public static func * (lhs: Vector2, rhs: Double) -> Vector2 {
    Vector2(x: lhs.x * rhs, y: lhs.y * rhs)
  }

  public func dot(_ other: Vector2) -> Double { x * other.x + y * other.y }
}

public struct Obstacle: Codable, Hashable, Sendable, Identifiable {
  public let id: String
  public let center: Vector2
  public let halfSize: Vector2
  public let height: Double

  public init(id: String, center: Vector2, halfSize: Vector2, height: Double) {
    self.id = id
    self.center = center
    self.halfSize = halfSize
    self.height = height
  }

  public func contains(_ point: Vector2, radius: Double = 0) -> Bool {
    abs(point.x - center.x) <= halfSize.x + radius && abs(point.y - center.y) <= halfSize.y + radius
  }

  public func reflectionNormal(at point: Vector2) -> Vector2 {
    let horizontalPenetration = halfSize.x - abs(point.x - center.x)
    let verticalPenetration = halfSize.y - abs(point.y - center.y)
    if horizontalPenetration <= verticalPenetration {
      return Vector2(x: point.x < center.x ? -1 : 1, y: 0)
    }
    return Vector2(x: 0, y: point.y < center.y ? -1 : 1)
  }
}

public struct Arena: Sendable {
  public let width: Double
  public let height: Double
  public let obstacles: [Obstacle]

  public init(width: Double, height: Double, obstacles: [Obstacle]) {
    precondition(width > 0 && height > 0)
    self.width = width
    self.height = height
    self.obstacles = obstacles
  }

  public func contains(_ point: Vector2, radius: Double = 0) -> Bool {
    point.x >= radius && point.x <= width - radius && point.y >= radius && point.y <= height - radius
  }

  public func collidingObstacle(at point: Vector2, altitude: Double, radius: Double = 0) -> Obstacle? {
    obstacles.first { obstacle in altitude <= obstacle.height && obstacle.contains(point, radius: radius) }
  }

  public func canOccupy(_ point: Vector2, altitude: Double, radius: Double = Tank.radius) -> Bool {
    contains(point, radius: radius) && collidingObstacle(at: point, altitude: altitude, radius: radius) == nil
  }

  /// A compact native arena with the boxed obstacles and open lanes characteristic of BZFlag maps.
  public static let classic = Arena(
    width: 120,
    height: 90,
    obstacles: [
      Obstacle(id: "northwest", center: Vector2(x: 28, y: 24), halfSize: Vector2(x: 7, y: 5), height: 5),
      Obstacle(id: "northeast", center: Vector2(x: 92, y: 24), halfSize: Vector2(x: 7, y: 5), height: 5),
      Obstacle(id: "center", center: Vector2(x: 60, y: 45), halfSize: Vector2(x: 8, y: 8), height: 6),
      Obstacle(id: "southwest", center: Vector2(x: 32, y: 68), halfSize: Vector2(x: 10, y: 4), height: 4),
      Obstacle(id: "southeast", center: Vector2(x: 88, y: 66), halfSize: Vector2(x: 6, y: 7), height: 5),
    ]
  )
}

public enum FlagKind: String, Codable, CaseIterable, Sendable {
  case jumping
  case quickTurn
  case ricochet

  public var title: String {
    switch self {
    case .jumping: "Jumping"
    case .quickTurn: "Quick Turn"
    case .ricochet: "Ricochet"
    }
  }

  public var abbreviation: String {
    switch self {
    case .jumping: "JP"
    case .quickTurn: "A"
    case .ricochet: "R"
    }
  }
}

public struct FlagPickup: Codable, Hashable, Sendable, Identifiable {
  public let id: UUID
  public let kind: FlagKind
  public var position: Vector2

  public init(id: UUID = UUID(), kind: FlagKind, position: Vector2) {
    self.id = id
    self.kind = kind
    self.position = position
  }
}

public struct Tank: Codable, Hashable, Sendable, Identifiable {
  public static let radius = 2.0
  public static let baseTurnRate = 0.25
  public static let quickTurnMultiplier = 1.5
  public static let jumpVelocity = 19.0

  public let id: UUID
  public var callsign: String
  public var position: Vector2
  public var heading: Double
  public var altitude: Double
  public var verticalVelocity: Double
  public var heldFlag: FlagKind?
  public var wins: Int
  public var losses: Int

  public init(
    id: UUID = UUID(), callsign: String, position: Vector2, heading: Double = 0, altitude: Double = 0,
    verticalVelocity: Double = 0, heldFlag: FlagKind? = nil, wins: Int = 0, losses: Int = 0
  ) {
    self.id = id
    self.callsign = callsign
    self.position = position
    self.heading = heading
    self.altitude = altitude
    self.verticalVelocity = verticalVelocity
    self.heldFlag = heldFlag
    self.wins = wins
    self.losses = losses
  }

  public var direction: Vector2 { Vector2(x: cos(heading), y: sin(heading)) }
}

public struct Projectile: Codable, Hashable, Sendable, Identifiable {
  public let id: UUID
  public let ownerID: UUID
  public var position: Vector2
  public var velocity: Vector2
  public var age: Double
  public let ricochets: Bool
  public var bounceCount: Int

  public init(ownerID: UUID, position: Vector2, heading: Double, ricochets: Bool) {
    id = UUID()
    self.ownerID = ownerID
    self.position = position
    velocity = Vector2(x: cos(heading), y: sin(heading)) * 36
    age = 0
    self.ricochets = ricochets
    bounceCount = 0
  }
}

public enum FireResult: Equatable, Sendable {
  case fired
  case reloading
}

public struct BZFlagMatch: Sendable {
  public let arena: Arena
  public var player: Tank
  public var opponent: Tank
  public var flags: [FlagPickup]
  public private(set) var projectiles: [Projectile] = []
  public private(set) var elapsed = 0.0
  public private(set) var reloadRemaining = 0.0
  public private(set) var lastEvent = "Find a flag, outmaneuver the other tank, and take the shot."
  private var opponentRespawnIndex = 0

  public init(
    arena: Arena = .classic,
    player: Tank = Tank(callsign: "Rogue", position: Vector2(x: 15, y: 45)),
    opponent: Tank = Tank(callsign: "Target", position: Vector2(x: 105, y: 45), heading: .pi),
    flags: [FlagPickup] = [
      FlagPickup(kind: .jumping, position: Vector2(x: 48, y: 20)),
      FlagPickup(kind: .quickTurn, position: Vector2(x: 74, y: 70)),
      FlagPickup(kind: .ricochet, position: Vector2(x: 60, y: 15)),
    ]
  ) {
    self.arena = arena
    self.player = player
    self.opponent = opponent
    self.flags = flags
  }

  @discardableResult
  public mutating func move(_ distance: Double) -> Bool {
    let destination = player.position + player.direction * distance
    guard arena.canOccupy(destination, altitude: player.altitude) else {
      lastEvent = "Building or arena wall blocks the tank."
      return false
    }
    player.position = destination
    collectNearbyFlag()
    return true
  }

  public mutating func turn(_ direction: Double) {
    let multiplier = player.heldFlag == .quickTurn ? Tank.quickTurnMultiplier : 1
    player.heading = normalizedAngle(player.heading + direction * Tank.baseTurnRate * multiplier)
  }

  @discardableResult
  public mutating func jump() -> Bool {
    guard player.altitude == 0 && (player.heldFlag == .jumping || jumpingIsEnabled) else {
      lastEvent = "Jumping requires level ground and the Jumping flag or an arena that permits it."
      return false
    }
    player.verticalVelocity = Tank.jumpVelocity
    lastEvent = "Jump initiated at 19 m/s; the tank can clear and see over low buildings."
    return true
  }

  public mutating func fire() -> FireResult {
    guard reloadRemaining <= 0 else {
      lastEvent = "Reloading: \(String(format: "%.1f", reloadRemaining)) seconds remaining."
      return .reloading
    }
    projectiles.append(
      Projectile(
        ownerID: player.id,
        position: player.position + player.direction * (Tank.radius + 0.25),
        heading: player.heading,
        ricochets: player.heldFlag == .ricochet
      )
    )
    reloadRemaining = 3.5
    lastEvent = player.heldFlag == .ricochet ? "Ricochet shot fired." : "Normal shot fired."
    return .fired
  }

  @discardableResult
  public mutating func dropFlag() -> Bool {
    guard let flag = player.heldFlag else {
      lastEvent = "No flag to drop."
      return false
    }
    flags.append(FlagPickup(kind: flag, position: player.position))
    player.heldFlag = nil
    lastEvent = "Dropped \(flag.title)."
    return true
  }

  public mutating func step(by delta: Double) {
    precondition(delta >= 0)
    elapsed += delta
    reloadRemaining = max(0, reloadRemaining - delta)
    updateJump(by: delta)
    updateProjectiles(by: delta)
    collectNearbyFlag()
  }

  private var jumpingIsEnabled: Bool { true }

  private mutating func updateJump(by delta: Double) {
    guard player.altitude > 0 || player.verticalVelocity > 0 else { return }
    player.verticalVelocity -= 9.8 * delta
    player.altitude += player.verticalVelocity * delta
    if player.altitude <= 0 {
      player.altitude = 0
      player.verticalVelocity = 0
      lastEvent = "Tank landed."
    }
  }

  private mutating func updateProjectiles(by delta: Double) {
    for index in projectiles.indices.reversed() {
      var projectile = projectiles[index]
      projectile.age += delta
      let next = projectile.position + projectile.velocity * delta
      guard projectile.age <= 3.5 && arena.contains(next) else {
        projectiles.remove(at: index)
        continue
      }
      if let obstacle = arena.collidingObstacle(at: next, altitude: 0.75) {
        guard projectile.ricochets, projectile.bounceCount < 2 else {
          projectiles.remove(at: index)
          continue
        }
        let normal = obstacle.reflectionNormal(at: next)
        projectile.velocity = projectile.velocity - normal * (2 * projectile.velocity.dot(normal))
        projectile.bounceCount += 1
        projectile.position = next
        projectiles[index] = projectile
        lastEvent = "Ricochet shot bounced from \(obstacle.id)."
        continue
      }
      projectile.position = next
      if projectile.ownerID != opponent.id && projectile.position.distance(to: opponent.position) <= Tank.radius {
        player.wins += 1
        opponent.losses += 1
        respawnOpponent()
        projectiles.remove(at: index)
        lastEvent = "Target destroyed: win recorded."
        continue
      }
      projectiles[index] = projectile
    }
  }

  private mutating func collectNearbyFlag() {
    guard player.altitude == 0,
      let index = flags.firstIndex(where: { $0.position.distance(to: player.position) <= Tank.radius + 0.75 })
    else { return }
    let flag = flags.remove(at: index)
    player.heldFlag = flag.kind
    lastEvent = "Picked up \(flag.kind.title) (\(flag.kind.abbreviation))."
  }

  private mutating func respawnOpponent() {
    let positions = [Vector2(x: 105, y: 20), Vector2(x: 105, y: 70), Vector2(x: 80, y: 45)]
    opponent.position = positions[opponentRespawnIndex % positions.count]
    opponent.heading = .pi
    opponentRespawnIndex += 1
  }

  private func normalizedAngle(_ angle: Double) -> Double {
    let fullTurn = Double.pi * 2
    let remainder = angle.truncatingRemainder(dividingBy: fullTurn)
    return remainder >= 0 ? remainder : remainder + fullTurn
  }
}
