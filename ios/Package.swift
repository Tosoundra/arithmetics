// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ArithmeticCore",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [.library(name: "ArithmeticCore", targets: ["ArithmeticCore"])],
    targets: [
        .target(name: "ArithmeticCore", path: "Arithmetics/Core"),
        .testTarget(name: "ArithmeticCoreTests", dependencies: ["ArithmeticCore"], path: "Tests/ArithmeticCoreTests")
    ]
)
