// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class CreateNoteMutation: GraphQLMutation {
    static let operationName: String = "CreateNote"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CreateNote($title: String!, $description: String! = "", $link: String! = "", $isFavorite: Boolean! = false) { createNote( title: $title description: $description link: $link isFavorite: $isFavorite ) { __typename id title description link isFavorite createdAt updatedAt } }"#
      ))

    public var title: String
    public var description: String
    public var link: String
    public var isFavorite: Bool

    public init(
      title: String,
      description: String = "",
      link: String = "",
      isFavorite: Bool = false
    ) {
      self.title = title
      self.description = description
      self.link = link
      self.isFavorite = isFavorite
    }

    public var __variables: Variables? { [
      "title": title,
      "description": description,
      "link": link,
      "isFavorite": isFavorite
    ] }

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("createNote", CreateNote.self, arguments: [
          "title": .variable("title"),
          "description": .variable("description"),
          "link": .variable("link"),
          "isFavorite": .variable("isFavorite")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        CreateNoteMutation.Data.self
      ] }

      var createNote: CreateNote { __data["createNote"] }

      /// CreateNote
      ///
      /// Parent Type: `NoteType`
      struct CreateNote: ChoozAPI.SelectionSet {
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
          CreateNoteMutation.Data.CreateNote.self
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