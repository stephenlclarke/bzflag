# BZFlag

<!-- markdownlint-disable MD013 -->
[![CI](https://github.com/stephenlclarke/bzflag/actions/workflows/ci.yml/badge.svg)](https://github.com/stephenlclarke/bzflag/actions/workflows/ci.yml)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_bzflag&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_bzflag)
[![Bugs](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_bzflag&metric=bugs)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_bzflag)
[![Code Smells](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_bzflag&metric=code_smells)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_bzflag)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_bzflag&metric=coverage)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_bzflag)
[![Duplicated Lines (%)](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_bzflag&metric=duplicated_lines_density)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_bzflag)
[![Lines of Code](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_bzflag&metric=ncloc)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_bzflag)
[![Reliability Rating](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_bzflag&metric=reliability_rating)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_bzflag)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_bzflag&metric=security_rating)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_bzflag)
[![Technical Debt](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_bzflag&metric=sqale_index)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_bzflag)
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_bzflag&metric=sqale_rating)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_bzflag)
[![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=stephenlclarke_bzflag&metric=vulnerabilities)](https://sonarcloud.io/summary/new_code?id=stephenlclarke_bzflag)

BZFlag is a native macOS SwiftUI remake of the classic 3D tank-battle game. It preserves the defining local game rules from the historical source: a tank arena with solid buildings, first-person view and radar, normal 3.5-second shots and reloads, Jumping at the original 19 m/s launch velocity, Quick Turn's 1.5× turn multiplier, Ricochet shots, flags picked up by driving over them, and win/loss scoring.

The app is a self-contained local arena mode with a native simulation and target tank; it does not implement the historical BZFlag server protocol. The original C/C++ client and server remain preserved under [`original/`](original) for reference, rather than being compiled or linked into this app.

## Requirements

- macOS 14 or later
- Swift 6.0 or later

## Build and run

```sh
swift build
swift test
./script/build_and_run.sh
```

The original BZFlag client drove the tank through the mouse movement box, fired with the left mouse button, dropped flags with middle mouse, and used `Tab` for jumping when the game or a Jumping flag allowed it. This native recreation maps deterministic desktop controls to the menu and visible buttons:

- `W` / `S`: drive forward / backward
- `A` / `D`: turn left / right
- `Space`: fire
- `Tab`: jump
- `E`: drop the current flag
- `R`: reset the local arena

## Install

```sh
brew tap stephenlclarke/tap
brew install --HEAD stephenlclarke/tap/bzflag
bzflag
```

## Quality workflow

```sh
make coverage-check
make sonar
```

`make coverage` emits `coverage.lcov` and SonarQube generic `coverage.xml`; `make sonar` requires that report and a `SONAR_TOKEN` (or `SONAR_TOKEN_PERSONAL`). The SonarCloud project key is `stephenlclarke_bzflag`.

## Historical source

[`original/`](original) is the official `1.7_archive_1` snapshot from [BZFlag-Dev/bzflag](https://github.com/BZFlag-Dev/bzflag), at upstream commit `723a7f040a67e42df44b422d722830c04439baa0`. Its retained README identifies it as BZFlag 1.7e7. See [`original/PROVENANCE.md`](original/PROVENANCE.md) for the exact import ref and licensing boundary.

## License

The native Swift implementation, build tooling, and documentation are MIT licensed; see [LICENSE](LICENSE). The archived historical source in `original/` remains under its retained GNU GPL version 2 terms.

<!-- markdownlint-enable MD013 -->
