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
                "UILaunchStoryboardName": .string("Launch Screen")
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
                .package(product: "Apollo")
            ]
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
