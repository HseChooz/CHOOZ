// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class CreateWishItemMutation: GraphQLMutation {
    static let operationName: String = "CreateWishItem"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CreateWishItem($title: String!, $description: String! = "") { createWishItem(title: $title, description: $description) { __typename id title description } }"#
      ))

    public var title: String
    public var description: String

    public init(
      title: String,
      description: String = ""
    ) {
      self.title = title
      self.description = description
    }

    public var __variables: Variables? { [
      "title": title,
      "description": description
    ] }

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("createWishItem", CreateWishItem.self, arguments: [
          "title": .variable("title"),
          "description": .variable("description")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        CreateWishItemMutation.Data.self
      ] }

      var createWishItem: CreateWishItem { __data["createWishItem"] }

      /// CreateWishItem
      ///
      /// Parent Type: `WishItemType`
      struct CreateWishItem: ChoozAPI.SelectionSet {
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
          CreateWishItemMutation.Data.CreateWishItem.self
        ] }

        var id: ChoozAPI.ID { __data["id"] }
        var title: String { __data["title"] }
        var description: String { __data["description"] }
      }
    }
  }

}