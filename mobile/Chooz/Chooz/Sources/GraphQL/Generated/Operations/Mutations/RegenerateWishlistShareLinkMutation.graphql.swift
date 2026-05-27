// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class RegenerateWishlistShareLinkMutation: GraphQLMutation {
    static let operationName: String = "RegenerateWishlistShareLink"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation RegenerateWishlistShareLink { regenerateWishlistShareLink { __typename url isEnabled } }"#
      ))

    public init() {}

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("regenerateWishlistShareLink", RegenerateWishlistShareLink.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        RegenerateWishlistShareLinkMutation.Data.self
      ] }

      var regenerateWishlistShareLink: RegenerateWishlistShareLink { __data["regenerateWishlistShareLink"] }

      /// RegenerateWishlistShareLink
      ///
      /// Parent Type: `WishlistShareLinkType`
      struct RegenerateWishlistShareLink: ChoozAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.WishlistShareLinkType }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("url", String.self),
          .field("isEnabled", Bool.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          RegenerateWishlistShareLinkMutation.Data.RegenerateWishlistShareLink.self
        ] }

        var url: String { __data["url"] }
        var isEnabled: Bool { __data["isEnabled"] }
      }
    }
  }

}