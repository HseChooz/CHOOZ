// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class AttachWishItemImageMutation: GraphQLMutation {
    static let operationName: String = "AttachWishItemImage"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AttachWishItemImage($id: ID!, $key: String!) { attachWishItemImage(id: $id, key: $key) { __typename id title description link price currency imageUrl } }"#
      ))

    public var id: ID
    public var key: String

    public init(
      id: ID,
      key: String
    ) {
      self.id = id
      self.key = key
    }

    public var __variables: Variables? { [
      "id": id,
      "key": key
    ] }

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("attachWishItemImage", AttachWishItemImage.self, arguments: [
          "id": .variable("id"),
          "key": .variable("key")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AttachWishItemImageMutation.Data.self
      ] }

      var attachWishItemImage: AttachWishItemImage { __data["attachWishItemImage"] }

      /// AttachWishItemImage
      ///
      /// Parent Type: `WishItemType`
      struct AttachWishItemImage: ChoozAPI.SelectionSet {
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
          AttachWishItemImageMutation.Data.AttachWishItemImage.self
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