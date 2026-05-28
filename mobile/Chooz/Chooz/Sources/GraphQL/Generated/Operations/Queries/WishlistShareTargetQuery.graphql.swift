// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class WishlistShareTargetQuery: GraphQLQuery {
    static let operationName: String = "WishlistShareTarget"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query WishlistShareTarget($token: String!) { wishlistShareTarget(token: $token) { __typename userId } }"#
      ))

    public var token: String

    public init(token: String) {
      self.token = token
    }

    public var __variables: Variables? { ["token": token] }

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("wishlistShareTarget", WishlistShareTarget.self, arguments: ["token": .variable("token")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        WishlistShareTargetQuery.Data.self
      ] }

      var wishlistShareTarget: WishlistShareTarget { __data["wishlistShareTarget"] }

      /// WishlistShareTarget
      ///
      /// Parent Type: `WishlistShareTargetType`
      struct WishlistShareTarget: ChoozAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.WishlistShareTargetType }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("userId", ChoozAPI.ID.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          WishlistShareTargetQuery.Data.WishlistShareTarget.self
        ] }

        var userId: ChoozAPI.ID { __data["userId"] }
      }
    }
  }

}