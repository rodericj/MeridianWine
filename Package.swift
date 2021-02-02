// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "App",
    products: [
        .executable(name: "App", targets: ["MeridianWine"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/swift-backtrace.git", from: "1.2.0"),
        .package(url: "https://github.com/rodericj/Meridian", from: "0.1.2"),
        .package(url: "https://github.com/GEOSwift/GEOSwift.git", from: "8.0.0"),
        .package(name: "SwiftgreSQL", url: "https://github.com/khanlou/SwiftgreSQL", from: "0.1.4"),
    ],
    targets: [
        .target(name: "MeridianWine",
                dependencies: [
                    "Meridian",
                    .product(name: "Backtrace", package: "swift-backtrace"),
                    .product(name: "GEOSwift", package: "GEOSwift"),
                    .product(name: "SwiftgreSQL", package: "SwiftgreSQL"),
                ],
                path: "Source"),
        //        .testTarget(name: "MeridianWineTests", dependencies: ["MeridianWine"], path: "MeridianWineTests"),
    ]
)

