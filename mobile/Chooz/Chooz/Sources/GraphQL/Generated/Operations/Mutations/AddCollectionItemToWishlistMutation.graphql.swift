// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class AddCollectionItemToWishlistMutation: GraphQLMutation {
    static let operationName: String = "AddCollectionItemToWishlist"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation AddCollectionItemToWishlist($collectionItemId: ID!) { addCollectionItemToWishlist(collectionItemId: $collectionItemId) { __typename id isAdded wishItemId } }"#
      ))

    public var collectionItemId: ID

    public init(collectionItemId: ID) {
      self.collectionItemId = collectionItemId
    }

    public var __variables: Variables? { ["collectionItemId": collectionItemId] }

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("addCollectionItemToWishlist", AddCollectionItemToWishlist.self, arguments: ["collectionItemId": .variable("collectionItemId")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AddCollectionItemToWishlistMutation.Data.self
      ] }

      var addCollectionItemToWishlist: AddCollectionItemToWishlist { __data["addCollectionItemToWishlist"] }

      /// AddCollectionItemToWishlist
      ///
      /// Parent Type: `CollectionItemType`
      struct AddCollectionItemToWishlist: ChoozAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.CollectionItemType }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", ChoozAPI.ID.self),
          .field("isAdded", Bool.self),
          .field("wishItemId", ChoozAPI.ID?.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          AddCollectionItemToWishlistMutation.Data.AddCollectionItemToWishlist.self
        ] }

        var id: ChoozAPI.ID { __data["id"] }
        var isAdded: Bool { __data["isAdded"] }
        var wishItemId: ChoozAPI.ID? { __data["wishItemId"] }
      }
    }
  }

}