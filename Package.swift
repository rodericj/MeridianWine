// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "App",
    products: [
        .executable(name: "App", targets: ["App"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/swift-backtrace.git", from: "1.2.0"),
        .package(url: "https://github.com/khanlou/Meridian", from: "0.2.1"),
        .package(name: "HTML", url: "https://github.com/robb/Swim", .revision("46d115e")),
        .package(url: "https://github.com/GEOSwift/GEOSwift.git", from: "8.0.0"),
        .package(name: "SwiftgreSQL", url: "https://github.com/khanlou/SwiftgreSQL", from: "0.1.4"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: ["MeridianWine"],
            resources: [.process("Static")]  // => files in the Static folder will be included in the bundle
        ),
        .target(
            name: "MeridianWine",
            dependencies: [
                "Meridian",
                .product(name: "HTML", package: "HTML"),
                .product(name: "Backtrace", package: "swift-backtrace"),
                .product(name: "GEOSwift", package: "GEOSwift"),
                .product(name: "SwiftgreSQL", package: "SwiftgreSQL")
            ]
        )
    ]
)

