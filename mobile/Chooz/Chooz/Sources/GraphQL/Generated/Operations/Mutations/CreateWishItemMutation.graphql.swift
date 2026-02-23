// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class CreateWishItemMutation: GraphQLMutation {
    static let operationName: String = "CreateWishItem"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CreateWishItem($title: String!, $description: String! = "", $link: String! = "", $price: Decimal = null, $currency: String! = "") { createWishItem( title: $title description: $description link: $link price: $price currency: $currency ) { __typename id title description link price currency imageUrl } }"#
      ))

    public var title: String
    public var description: String
    public var link: String
    public var price: GraphQLNullable<Decimal>
    public var currency: String

    public init(
      title: String,
      description: String = "",
      link: String = "",
      price: GraphQLNullable<Decimal> = .null,
      currency: String = ""
    ) {
      self.title = title
      self.description = description
      self.link = link
      self.price = price
      self.currency = currency
    }

    public var __variables: Variables? { [
      "title": title,
      "description": description,
      "link": link,
      "price": price,
      "currency": currency
    ] }

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("createWishItem", CreateWishItem.self, arguments: [
          "title": .variable("title"),
          "description": .variable("description"),
          "link": .variable("link"),
          "price": .variable("price"),
          "currency": .variable("currency")
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
          .field("link", String?.self),
          .field("price", Double?.self),
          .field("currency", String?.self),
          .field("imageUrl", String?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          CreateWishItemMutation.Data.CreateWishItem.self
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