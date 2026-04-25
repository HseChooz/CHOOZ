// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class CollectionQuery: GraphQLQuery {
    static let operationName: String = "Collection"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Collection($slug: String!) { collection(slug: $slug) { __typename id slug title subtitle description badge coverImageUrl sectionKey sectionTitle tags itemsCount items { __typename id title description link price currency tags imageUrl isAdded wishItemId } } }"#
      ))

    public var slug: String

    public init(slug: String) {
      self.slug = slug
    }

    public var __variables: Variables? { ["slug": slug] }

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("collection", Collection?.self, arguments: ["slug": .variable("slug")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        CollectionQuery.Data.self
      ] }

      var collection: Collection? { __data["collection"] }

      /// Collection
      ///
      /// Parent Type: `CollectionType`
      struct Collection: ChoozAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.CollectionType }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", ChoozAPI.ID.self),
          .field("slug", String.self),
          .field("title", String.self),
          .field("subtitle", String.self),
          .field("description", String.self),
          .field("badge", String?.self),
          .field("coverImageUrl", String?.self),
          .field("sectionKey", String.self),
          .field("sectionTitle", String.self),
          .field("tags", [String].self),
          .field("itemsCount", Int.self),
          .field("items", [Item].self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          CollectionQuery.Data.Collection.self
        ] }

        var id: ChoozAPI.ID { __data["id"] }
        var slug: String { __data["slug"] }
        var title: String { __data["title"] }
        var subtitle: String { __data["subtitle"] }
        var description: String { __data["description"] }
        var badge: String? { __data["badge"] }
        var coverImageUrl: String? { __data["coverImageUrl"] }
        var sectionKey: String { __data["sectionKey"] }
        var sectionTitle: String { __data["sectionTitle"] }
        var tags: [String] { __data["tags"] }
        var itemsCount: Int { __data["itemsCount"] }
        var items: [Item] { __data["items"] }

        /// Collection.Item
        ///
        /// Parent Type: `CollectionItemType`
        struct Item: ChoozAPI.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.CollectionItemType }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", ChoozAPI.ID.self),
            .field("title", String.self),
            .field("description", String.self),
            .field("link", String?.self),
            .field("price", Double?.self),
            .field("currency", String?.self),
            .field("tags", [String].self),
            .field("imageUrl", String?.self),
            .field("isAdded", Bool.self),
            .field("wishItemId", ChoozAPI.ID?.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            CollectionQuery.Data.Collection.Item.self
          ] }

          var id: ChoozAPI.ID { __data["id"] }
          var title: String { __data["title"] }
          var description: String { __data["description"] }
          var link: String? { __data["link"] }
          var price: Double? { __data["price"] }
          var currency: String? { __data["currency"] }
          var tags: [String] { __data["tags"] }
          var imageUrl: String? { __data["imageUrl"] }
          var isAdded: Bool { __data["isAdded"] }
          var wishItemId: ChoozAPI.ID? { __data["wishItemId"] }
        }
      }
    }
  }

}