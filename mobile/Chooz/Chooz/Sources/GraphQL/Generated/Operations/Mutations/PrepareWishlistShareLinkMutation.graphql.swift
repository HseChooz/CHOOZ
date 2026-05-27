// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class PrepareWishlistShareLinkMutation: GraphQLMutation {
    static let operationName: String = "PrepareWishlistShareLink"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation PrepareWishlistShareLink { prepareWishlistShareLink { __typename url isEnabled } }"#
      ))

    public init() {}

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("prepareWishlistShareLink", PrepareWishlistShareLink.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        PrepareWishlistShareLinkMutation.Data.self
      ] }

      var prepareWishlistShareLink: PrepareWishlistShareLink { __data["prepareWishlistShareLink"] }

      /// PrepareWishlistShareLink
      ///
      /// Parent Type: `WishlistShareLinkType`
      struct PrepareWishlistShareLink: ChoozAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.WishlistShareLinkType }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("url", String.self),
          .field("isEnabled", Bool.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          PrepareWishlistShareLinkMutation.Data.PrepareWishlistShareLink.self
        ] }

        var url: String { __data["url"] }
        var isEnabled: Bool { __data["isEnabled"] }
      }
    }
  }

}