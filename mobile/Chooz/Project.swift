import ProjectDescription

let project = Project(
    name: "Chooz",
    packages: [
        .package(url: "https://github.com/apollographql/apollo-ios.git", .upToNextMajor(from: "1.7.0"))
    ],
    targets: [
        .target(
            name: "Chooz",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.Chooz",
            infoPlist: .extendingDefault(with: [
                "UILaunchStoryboardName": .string("Launch Screen"),
                "UISupportedInterfaceOrientations": .array([
                    .string("UIInterfaceOrientationPortrait")
                ]),
                "UIAppFonts": .array([
                    .string("VelaSans-ExtraLight.ttf"),
                    .string("VelaSans-Light.ttf"),
                    .string("VelaSans-Regular.ttf"),
                    .string("VelaSans-Medium.ttf"),
                    .string("VelaSans-SemiBold.ttf"),
                    .string("VelaSans-Bold.ttf"),
                    .string("VelaSans-ExtraBold.ttf")
                ]),
                "CFBundleURLTypes": .array([
                    .dictionary([
                        "CFBundleURLSchemes": .array([
                            .string("com.googleusercontent.apps.997450664376-be282n3v8e24voj4t16e35l9luqq22t1")
                        ])
                    ])
                ]),
                "GIDClientID": .string("997450664376-be282n3v8e24voj4t16e35l9luqq22t1.apps.googleusercontent.com"),
                "APIBaseURL": .string("$(API_BASE_URL)"),
                "UIApplicationSceneManifest": .dictionary([
                    "UIApplicationSupportsMultipleScenes": .boolean(false),
                    "UISceneConfigurations": .dictionary([:])
                ]),
                "UIDesignRequiresCompatibility": .boolean(true),
                "NSAppTransportSecurity": .dictionary([
                    "NSExceptionDomains": .dictionary([
                        "94.198.132.110": .dictionary([
                            "NSExceptionAllowsInsecureHTTPLoads": .boolean(true),
                            "NSIncludesSubdomains": .boolean(true)
                        ])
                    ])
                ])
            ]),
            sources: ["Chooz/Sources/**"],
            resources: ["Chooz/Resources/**"],
            scripts: [
                .pre(
                    path: .relativeToRoot("../tools/graphql/apollo_codegen.sh"),
                    name: "Apollo GraphQL Codegen",
                    basedOnDependencyAnalysis: false
                )
            ],
            dependencies: [
                .package(product: "Apollo"),
                .external(name: "GoogleSignIn")
            ],
            settings: .settings(
                base: [
                    "OTHER_LDFLAGS": "-ObjC"
                ],
                configurations: [
                    .debug(name: "Debug", settings: [
                        "API_BASE_URL": "http://94.198.132.110:8010/api/graphql/"
                    ]),
                    .release(name: "Release", settings: [
                        "API_BASE_URL": "https://api.chooz.app/graphql/"
                    ])
                ]
            )
        ),
        .target(
            name: "ChoozTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.ChoozTests",
            infoPlist: .default,
            sources: ["Chooz/Tests/**"],
            dependencies: [.target(name: "Chooz")]
        ),
    ]
)
