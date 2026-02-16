// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [:]
    )
#endif

let package = Package(
    name: "Chooz",
    dependencies: [
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "8.0.0"),
        .package(url: "https://github.com/yandexmobile/yandex-login-sdk-ios", from: "3.0.0")
    ]
)
