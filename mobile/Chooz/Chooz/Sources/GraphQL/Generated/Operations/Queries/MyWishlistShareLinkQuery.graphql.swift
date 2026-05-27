// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class MyWishlistShareLinkQuery: GraphQLQuery {
    static let operationName: String = "MyWishlistShareLink"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query MyWishlistShareLink { myWishlistShareLink { __typename url isEnabled } }"#
      ))

    public init() {}

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("myWishlistShareLink", MyWishlistShareLink?.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MyWishlistShareLinkQuery.Data.self
      ] }

      var myWishlistShareLink: MyWishlistShareLink? { __data["myWishlistShareLink"] }

      /// MyWishlistShareLink
      ///
      /// Parent Type: `WishlistShareLinkType`
      struct MyWishlistShareLink: ChoozAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.WishlistShareLinkType }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("url", String.self),
          .field("isEnabled", Bool.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MyWishlistShareLinkQuery.Data.MyWishlistShareLink.self
        ] }

        var url: String { __data["url"] }
        var isEnabled: Bool { __data["isEnabled"] }
      }
    }
  }

}