// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class DisableWishlistShareLinkMutation: GraphQLMutation {
    static let operationName: String = "DisableWishlistShareLink"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation DisableWishlistShareLink { disableWishlistShareLink { __typename url isEnabled } }"#
      ))

    public init() {}

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("disableWishlistShareLink", DisableWishlistShareLink.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        DisableWishlistShareLinkMutation.Data.self
      ] }

      var disableWishlistShareLink: DisableWishlistShareLink { __data["disableWishlistShareLink"] }

      /// DisableWishlistShareLink
      ///
      /// Parent Type: `WishlistShareLinkType`
      struct DisableWishlistShareLink: ChoozAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.WishlistShareLinkType }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("url", String.self),
          .field("isEnabled", Bool.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          DisableWishlistShareLinkMutation.Data.DisableWishlistShareLink.self
        ] }

        var url: String { __data["url"] }
        var isEnabled: Bool { __data["isEnabled"] }
      }
    }
  }

}