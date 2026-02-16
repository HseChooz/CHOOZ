// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class WishItemsQuery: GraphQLQuery {
    static let operationName: String = "WishItems"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query WishItems { wishItems { __typename id title description } }"#
      ))

    public init() {}

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("wishItems", [WishItem].self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        WishItemsQuery.Data.self
      ] }

      var wishItems: [WishItem] { __data["wishItems"] }

      /// WishItem
      ///
      /// Parent Type: `WishItemType`
      struct WishItem: ChoozAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.WishItemType }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", ChoozAPI.ID.self),
          .field("title", String.self),
          .field("description", String.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          WishItemsQuery.Data.WishItem.self
        ] }

        var id: ChoozAPI.ID { __data["id"] }
        var title: String { __data["title"] }
        var description: String { __data["description"] }
      }
    }
  }

}