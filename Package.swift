// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "MeridianWine",
    products: [
        .executable(name: "MeridianWine", targets: ["MeridianWine"]),
    ],
    dependencies: [
        .package(url: "https://github.com/rodericj/Meridian", from: "0.1.2"),
        .package(url: "https://github.com/GEOSwift/GEOSwift.git", from: "8.0.0"),
    ],
    targets: [
        .target(name: "MeridianWine",
                dependencies: ["Meridian",
                               .product(name: "GEOSwift", package: "GEOSwift")
                ],
                path: "Source"),
        //        .testTarget(name: "MeridianWineTests", dependencies: ["MeridianWine"], path: "MeridianWineTests"),
    ]
)

