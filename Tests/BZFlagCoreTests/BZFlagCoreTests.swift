import Testing

@testable import BZFlagCore

private let testArena = Arena(
  width: 30,
  height: 20,
  obstacles: [Obstacle(id: "box", center: Vector2(x: 15, y: 10), halfSize: Vector2(x: 1, y: 3), height: 4)]
)

@Test func groundTankCannotDriveThroughABuilding() {
  var match = BZFlagMatch(
    arena: testArena,
    player: Tank(callsign: "Player", position: Vector2(x: 10, y: 10)),
    opponent: Tank(callsign: "Opponent", position: Vector2(x: 25, y: 10)),
    flags: []
  )

  let moved = match.move(4)

  #expect(!moved)
  #expect(match.player.position == Vector2(x: 10, y: 10))
}

@Test func jumpingUsesTheHistoricalLaunchVelocityAndClearsLowObstacleCollision() {
  var match = BZFlagMatch(
    arena: testArena,
    player: Tank(callsign: "Player", position: Vector2(x: 10, y: 10)),
    opponent: Tank(callsign: "Opponent", position: Vector2(x: 25, y: 10)),
    flags: []
  )

  let jumped = match.jump()
  match.step(by: 0.5)
  let movedOverBuilding = match.move(5)
  match.step(by: 3)

  #expect(jumped)
  #expect(match.player.altitude == 0)
  #expect(movedOverBuilding)
  #expect(match.player.position == Vector2(x: 15, y: 10))
}

@Test func quickTurnFlagUsesTheLegacyOnePointFiveMultiplier() {
  var normal = BZFlagMatch(arena: testArena, flags: [])
  var quick = BZFlagMatch(
    arena: testArena,
    player: Tank(callsign: "Quick", position: Vector2(x: 5, y: 5), heldFlag: .quickTurn),
    flags: []
  )

  normal.turn(1)
  quick.turn(1)

  #expect(normal.player.heading == Tank.baseTurnRate)
  #expect(quick.player.heading == Tank.baseTurnRate * Tank.quickTurnMultiplier)
}

@Test func flagsAreCollectedFromGroundAndCanBeDropped() {
  let flag = FlagPickup(kind: .ricochet, position: Vector2(x: 5, y: 5))
  var match = BZFlagMatch(
    arena: testArena,
    player: Tank(callsign: "Player", position: Vector2(x: 5, y: 5)),
    flags: [flag]
  )

  match.step(by: 0)
  let dropped = match.dropFlag()

  #expect(match.player.heldFlag == nil)
  #expect(dropped)
  #expect(match.flags.map(\.kind) == [.ricochet])
}

@Test func normalShotDestroysTargetAndRecordsAWin() {
  let openArena = Arena(width: 40, height: 20, obstacles: [])
  var match = BZFlagMatch(
    arena: openArena,
    player: Tank(callsign: "Player", position: Vector2(x: 3, y: 10)),
    opponent: Tank(callsign: "Target", position: Vector2(x: 12, y: 10)),
    flags: []
  )

  let fired = match.fire()
  match.step(by: 0.19)

  #expect(fired == .fired)
  #expect(match.player.wins == 1)
  #expect(match.opponent.losses == 1)
  #expect(match.projectiles.isEmpty)
}

@Test func ricochetShotsBounceButNormalShotsStopAtBuildings() {
  var ricochet = BZFlagMatch(
    arena: testArena,
    player: Tank(callsign: "Player", position: Vector2(x: 10, y: 10), heldFlag: .ricochet),
    flags: []
  )
  var normal = BZFlagMatch(
    arena: testArena,
    player: Tank(callsign: "Player", position: Vector2(x: 10, y: 10)),
    flags: []
  )

  _ = ricochet.fire()
  _ = normal.fire()
  ricochet.step(by: 0.1)
  normal.step(by: 0.1)

  #expect(ricochet.projectiles.count == 1)
  #expect(ricochet.projectiles[0].velocity.x < 0)
  #expect(normal.projectiles.isEmpty)
}

@Test func reloadPreventsImmediateSecondShot() {
  var match = BZFlagMatch(arena: testArena, flags: [])

  let first = match.fire()
  let second = match.fire()
  match.step(by: 3.5)
  let third = match.fire()

  #expect(first == .fired)
  #expect(second == .reloading)
  #expect(third == .fired)
}
