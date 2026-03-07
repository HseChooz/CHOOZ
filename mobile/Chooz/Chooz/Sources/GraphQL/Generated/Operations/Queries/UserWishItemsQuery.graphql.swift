// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class UserWishItemsQuery: GraphQLQuery {
    static let operationName: String = "UserWishItems"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query UserWishItems($userId: ID!) { userWishItems(userId: $userId) { __typename user { __typename id username firstName lastName } items { __typename id title description link price currency imageUrl } } }"#
      ))

    public var userId: ID

    public init(userId: ID) {
      self.userId = userId
    }

    public var __variables: Variables? { ["userId": userId] }

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("userWishItems", UserWishItems.self, arguments: ["userId": .variable("userId")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        UserWishItemsQuery.Data.self
      ] }

      var userWishItems: UserWishItems { __data["userWishItems"] }

      /// UserWishItems
      ///
      /// Parent Type: `UserWishItemsResult`
      struct UserWishItems: ChoozAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.UserWishItemsResult }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("user", User.self),
          .field("items", [Item].self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          UserWishItemsQuery.Data.UserWishItems.self
        ] }

        var user: User { __data["user"] }
        var items: [Item] { __data["items"] }

        /// UserWishItems.User
        ///
        /// Parent Type: `UserType`
        struct User: ChoozAPI.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.UserType }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", ChoozAPI.ID.self),
            .field("username", String.self),
            .field("firstName", String.self),
            .field("lastName", String.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            UserWishItemsQuery.Data.UserWishItems.User.self
          ] }

          var id: ChoozAPI.ID { __data["id"] }
          var username: String { __data["username"] }
          var firstName: String { __data["firstName"] }
          var lastName: String { __data["lastName"] }
        }

        /// UserWishItems.Item
        ///
        /// Parent Type: `WishItemType`
        struct Item: ChoozAPI.SelectionSet {
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
            UserWishItemsQuery.Data.UserWishItems.Item.self
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

}