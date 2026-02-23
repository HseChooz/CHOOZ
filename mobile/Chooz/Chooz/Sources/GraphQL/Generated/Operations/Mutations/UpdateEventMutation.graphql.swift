// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class UpdateEventMutation: GraphQLMutation {
    static let operationName: String = "UpdateEvent"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation UpdateEvent($id: ID!, $title: String, $description: String, $link: String, $date: Date, $notifyEnabled: Boolean, $repeatYearly: Boolean) { updateEvent( id: $id title: $title description: $description link: $link date: $date notifyEnabled: $notifyEnabled repeatYearly: $repeatYearly ) { __typename id title description link notifyEnabled repeatYearly date } }"#
      ))

    public var id: ID
    public var title: GraphQLNullable<String>
    public var description: GraphQLNullable<String>
    public var link: GraphQLNullable<String>
    public var date: GraphQLNullable<Date>
    public var notifyEnabled: GraphQLNullable<Bool>
    public var repeatYearly: GraphQLNullable<Bool>

    public init(
      id: ID,
      title: GraphQLNullable<String>,
      description: GraphQLNullable<String>,
      link: GraphQLNullable<String>,
      date: GraphQLNullable<Date>,
      notifyEnabled: GraphQLNullable<Bool>,
      repeatYearly: GraphQLNullable<Bool>
    ) {
      self.id = id
      self.title = title
      self.description = description
      self.link = link
      self.date = date
      self.notifyEnabled = notifyEnabled
      self.repeatYearly = repeatYearly
    }

    public var __variables: Variables? { [
      "id": id,
      "title": title,
      "description": description,
      "link": link,
      "date": date,
      "notifyEnabled": notifyEnabled,
      "repeatYearly": repeatYearly
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
          "link": .variable("link"),
          "date": .variable("date"),
          "notifyEnabled": .variable("notifyEnabled"),
          "repeatYearly": .variable("repeatYearly")
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
          .field("link", String?.self),
          .field("notifyEnabled", Bool.self),
          .field("repeatYearly", Bool.self),
          .field("date", ChoozAPI.Date.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          UpdateEventMutation.Data.UpdateEvent.self
        ] }

        var id: ChoozAPI.ID { __data["id"] }
        var title: String { __data["title"] }
        var description: String { __data["description"] }
        var link: String? { __data["link"] }
        var notifyEnabled: Bool { __data["notifyEnabled"] }
        var repeatYearly: Bool { __data["repeatYearly"] }
        var date: ChoozAPI.Date { __data["date"] }
      }
    }
  }

}