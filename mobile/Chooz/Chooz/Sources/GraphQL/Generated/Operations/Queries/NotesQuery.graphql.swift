// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class NotesQuery: GraphQLQuery {
    static let operationName: String = "Notes"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Notes($onlyFavorites: Boolean!) { notes(onlyFavorites: $onlyFavorites) { __typename id title description link isFavorite createdAt updatedAt } }"#
      ))

    public var onlyFavorites: Bool

    public init(onlyFavorites: Bool) {
      self.onlyFavorites = onlyFavorites
    }

    public var __variables: Variables? { ["onlyFavorites": onlyFavorites] }

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("notes", [Note].self, arguments: ["onlyFavorites": .variable("onlyFavorites")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        NotesQuery.Data.self
      ] }

      var notes: [Note] { __data["notes"] }

      /// Note
      ///
      /// Parent Type: `NoteType`
      struct Note: ChoozAPI.SelectionSet {
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
          NotesQuery.Data.Note.self
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