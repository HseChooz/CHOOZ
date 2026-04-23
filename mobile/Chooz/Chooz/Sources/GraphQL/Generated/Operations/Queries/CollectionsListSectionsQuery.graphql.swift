// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class CollectionsListSectionsQuery: GraphQLQuery {
    static let operationName: String = "CollectionsListSections"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query CollectionsListSections($search: String = null) { collectionSections(search: $search) { __typename key title collections { __typename id slug title subtitle badge coverImageUrl itemsCount } } }"#
      ))

    public var search: GraphQLNullable<String>

    public init(search: GraphQLNullable<String> = .null) {
      self.search = search
    }

    public var __variables: Variables? { ["search": search] }

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("collectionSections", [CollectionSection].self, arguments: ["search": .variable("search")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        CollectionsListSectionsQuery.Data.self
      ] }

      var collectionSections: [CollectionSection] { __data["collectionSections"] }

      /// CollectionSection
      ///
      /// Parent Type: `CollectionSectionType`
      struct CollectionSection: ChoozAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.CollectionSectionType }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("key", String.self),
          .field("title", String.self),
          .field("collections", [Collection].self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          CollectionsListSectionsQuery.Data.CollectionSection.self
        ] }

        var key: String { __data["key"] }
        var title: String { __data["title"] }
        var collections: [Collection] { __data["collections"] }

        /// CollectionSection.Collection
        ///
        /// Parent Type: `CollectionPreviewType`
        struct Collection: ChoozAPI.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.CollectionPreviewType }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", ChoozAPI.ID.self),
            .field("slug", String.self),
            .field("title", String.self),
            .field("subtitle", String.self),
            .field("badge", String?.self),
            .field("coverImageUrl", String?.self),
            .field("itemsCount", Int.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            CollectionsListSectionsQuery.Data.CollectionSection.Collection.self
          ] }

          var id: ChoozAPI.ID { __data["id"] }
          var slug: String { __data["slug"] }
          var title: String { __data["title"] }
          var subtitle: String { __data["subtitle"] }
          var badge: String? { __data["badge"] }
          var coverImageUrl: String? { __data["coverImageUrl"] }
          var itemsCount: Int { __data["itemsCount"] }
        }
      }
    }
  }

}