// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class UpdateEventMutation: GraphQLMutation {
    static let operationName: String = "UpdateEvent"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation UpdateEvent($id: ID!, $title: String, $description: String, $date: Date) { updateEvent(id: $id, title: $title, description: $description, date: $date) { __typename id title description date } }"#
      ))

    public var id: ID
    public var title: GraphQLNullable<String>
    public var description: GraphQLNullable<String>
    public var date: GraphQLNullable<Date>

    public init(
      id: ID,
      title: GraphQLNullable<String>,
      description: GraphQLNullable<String>,
      date: GraphQLNullable<Date>
    ) {
      self.id = id
      self.title = title
      self.description = description
      self.date = date
    }

    public var __variables: Variables? { [
      "id": id,
      "title": title,
      "description": description,
      "date": date
    ] }

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("updateEvent", UpdateEvent.self, arguments: [
          "id": .variable("id"),
          "title": .variable("title"),
          "description": .variable("description"),
          "date": .variable("date")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        UpdateEventMutation.Data.self
      ] }

      var updateEvent: UpdateEvent { __data["updateEvent"] }

      /// UpdateEvent
      ///
      /// Parent Type: `EventType`
      struct UpdateEvent: ChoozAPI.SelectionSet {
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
          UpdateEventMutation.Data.UpdateEvent.self
        ] }

        var id: ChoozAPI.ID { __data["id"] }
        var title: String { __data["title"] }
        var description: String { __data["description"] }
        var date: ChoozAPI.Date { __data["date"] }
      }
    }
  }

}