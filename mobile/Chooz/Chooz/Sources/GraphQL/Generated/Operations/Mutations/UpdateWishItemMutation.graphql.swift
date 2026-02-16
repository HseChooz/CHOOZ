// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class UpdateWishItemMutation: GraphQLMutation {
    static let operationName: String = "UpdateWishItem"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation UpdateWishItem($id: ID!, $title: String, $description: String) { updateWishItem(id: $id, title: $title, description: $description) { __typename id title description } }"#
      ))

    public var id: ID
    public var title: GraphQLNullable<String>
    public var description: GraphQLNullable<String>

    public init(
      id: ID,
      title: GraphQLNullable<String>,
      description: GraphQLNullable<String>
    ) {
      self.id = id
      self.title = title
      self.description = description
    }

    public var __variables: Variables? { [
      "id": id,
      "title": title,
      "description": description
    ] }

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("updateWishItem", UpdateWishItem.self, arguments: [
          "id": .variable("id"),
          "title": .variable("title"),
          "description": .variable("description")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        UpdateWishItemMutation.Data.self
      ] }

      var updateWishItem: UpdateWishItem { __data["updateWishItem"] }

      /// UpdateWishItem
      ///
      /// Parent Type: `WishItemType`
      struct UpdateWishItem: ChoozAPI.SelectionSet {
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
          UpdateWishItemMutation.Data.UpdateWishItem.self
        ] }

        var id: ChoozAPI.ID { __data["id"] }
        var title: String { __data["title"] }
        var description: String { __data["description"] }
      }
    }
  }

}