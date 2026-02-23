// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class WishItemQuery: GraphQLQuery {
    static let operationName: String = "WishItem"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query WishItem($id: ID!) { wishItem(id: $id) { __typename id title description link price currency imageUrl } }"#
      ))

    public var id: ID

    public init(id: ID) {
      self.id = id
    }

    public var __variables: Variables? { ["id": id] }

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("wishItem", WishItem.self, arguments: ["id": .variable("id")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        WishItemQuery.Data.self
      ] }

      var wishItem: WishItem { __data["wishItem"] }

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
          .field("link", String?.self),
          .field("price", Double?.self),
          .field("currency", String?.self),
          .field("imageUrl", String?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          WishItemQuery.Data.WishItem.self
        ] }

        var id: ChoozAPI.ID { __data["id"] }
        var title: String { __data["title"] }
        var description: String { __data["description"] }
        var link: String? { __data["link"] }
        var price: Double? { __data["price"] }
        var currency: String? { __data["currency"] }
        var imageUrl: String? { __data["imageUrl"] }
      }
    }
  }

}