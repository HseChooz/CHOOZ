// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class UpdateNoteFavoriteMutation: GraphQLMutation {
    static let operationName: String = "UpdateNoteFavorite"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation UpdateNoteFavorite($id: ID!, $isFavorite: Boolean!) { updateNote(id: $id, isFavorite: $isFavorite) { __typename id title description link isFavorite createdAt updatedAt } }"#
      ))

    public var id: ID
    public var isFavorite: Bool

    public init(
      id: ID,
      isFavorite: Bool
    ) {
      self.id = id
      self.isFavorite = isFavorite
    }

    public var __variables: Variables? { [
      "id": id,
      "isFavorite": isFavorite
    ] }

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("updateNote", UpdateNote.self, arguments: [
          "id": .variable("id"),
          "isFavorite": .variable("isFavorite")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        UpdateNoteFavoriteMutation.Data.self
      ] }

      var updateNote: UpdateNote { __data["updateNote"] }

      /// UpdateNote
      ///
      /// Parent Type: `NoteType`
      struct UpdateNote: ChoozAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.NoteType }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", ChoozAPI.ID.self),
          .field("title", String.self),
          .field("description", String.self),
          .field("link", String?.self),
          .field("isFavorite", Bool.self),
          .field("createdAt", ChoozAPI.DateTime.self),
          .field("updatedAt", ChoozAPI.DateTime.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          UpdateNoteFavoriteMutation.Data.UpdateNote.self
        ] }

        var id: ChoozAPI.ID { __data["id"] }
        var title: String { __data["title"] }
        var description: String { __data["description"] }
        var link: String? { __data["link"] }
        var isFavorite: Bool { __data["isFavorite"] }
        var createdAt: ChoozAPI.DateTime { __data["createdAt"] }
        var updatedAt: ChoozAPI.DateTime { __data["updatedAt"] }
      }
    }
  }

}