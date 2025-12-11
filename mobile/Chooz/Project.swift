import ProjectDescription

let project = Project(
    name: "Chooz",
    targets: [
        .target(
            name: "Chooz",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.Chooz",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            buildableFolders: [
                "Chooz/Sources",
                "Chooz/Resources",
            ],
            dependencies: []
        ),
        .target(
            name: "ChoozTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.ChoozTests",
            infoPlist: .default,
            buildableFolders: [
                "Chooz/Tests"
            ],
            dependencies: [.target(name: "Chooz")]
        ),
    ]
)
