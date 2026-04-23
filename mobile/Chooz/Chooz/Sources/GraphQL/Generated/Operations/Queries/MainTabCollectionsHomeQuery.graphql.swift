// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class MainTabCollectionsHomeQuery: GraphQLQuery {
    static let operationName: String = "MainTabCollectionsHome"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query MainTabCollectionsHome { collectionsHome { __typename sections { __typename key title collections { __typename id slug title subtitle badge coverImageUrl itemsCount } } } }"#
      ))

    public init() {}

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("collectionsHome", CollectionsHome.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MainTabCollectionsHomeQuery.Data.self
      ] }

      var collectionsHome: CollectionsHome { __data["collectionsHome"] }

      /// CollectionsHome
      ///
      /// Parent Type: `CollectionsHomeType`
      struct CollectionsHome: ChoozAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.CollectionsHomeType }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("sections", [Section].self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MainTabCollectionsHomeQuery.Data.CollectionsHome.self
        ] }

        var sections: [Section] { __data["sections"] }

        /// CollectionsHome.Section
        ///
        /// Parent Type: `CollectionSectionType`
        struct Section: ChoozAPI.SelectionSet {
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
            MainTabCollectionsHomeQuery.Data.CollectionsHome.Section.self
          ] }

          var key: String { __data["key"] }
          var title: String { __data["title"] }
          var collections: [Collection] { __data["collections"] }

          /// CollectionsHome.Section.Collection
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
              MainTabCollectionsHomeQuery.Data.CollectionsHome.Section.Collection.self
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

}