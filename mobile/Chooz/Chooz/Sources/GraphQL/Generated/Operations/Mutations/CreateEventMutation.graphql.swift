// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class CreateEventMutation: GraphQLMutation {
    static let operationName: String = "CreateEvent"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CreateEvent($title: String!, $date: Date!, $description: String! = "") { createEvent(title: $title, date: $date, description: $description) { __typename id title description date } }"#
      ))

    public var title: String
    public var date: Date
    public var description: String

    public init(
      title: String,
      date: Date,
      description: String = ""
    ) {
      self.title = title
      self.date = date
      self.description = description
    }

    public var __variables: Variables? { [
      "title": title,
      "date": date,
      "description": description
    ] }

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("createEvent", CreateEvent.self, arguments: [
          "title": .variable("title"),
          "date": .variable("date"),
          "description": .variable("description")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        CreateEventMutation.Data.self
      ] }

      var createEvent: CreateEvent { __data["createEvent"] }

      /// CreateEvent
      ///
      /// Parent Type: `EventType`
      struct CreateEvent: ChoozAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.EventType }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", ChoozAPI.ID.self),
          .field("title", String.self),
          .field("description", String.self),
          .field("date", ChoozAPI.Date.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          CreateEventMutation.Data.CreateEvent.self
        ] }

        var id: ChoozAPI.ID { __data["id"] }
        var title: String { __data["title"] }
        var description: String { __data["description"] }
        var date: ChoozAPI.Date { __data["date"] }
      }
    }
  }

}