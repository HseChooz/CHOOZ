// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class CreateEventMutation: GraphQLMutation {
    static let operationName: String = "CreateEvent"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CreateEvent($title: String!, $date: Date!, $description: String! = "", $link: String! = "", $notifyEnabled: Boolean! = false, $repeatYearly: Boolean! = false) { createEvent( title: $title date: $date description: $description link: $link notifyEnabled: $notifyEnabled repeatYearly: $repeatYearly ) { __typename id title description link notifyEnabled repeatYearly date } }"#
      ))

    public var title: String
    public var date: Date
    public var description: String
    public var link: String
    public var notifyEnabled: Bool
    public var repeatYearly: Bool

    public init(
      title: String,
      date: Date,
      description: String = "",
      link: String = "",
      notifyEnabled: Bool = false,
      repeatYearly: Bool = false
    ) {
      self.title = title
      self.date = date
      self.description = description
      self.link = link
      self.notifyEnabled = notifyEnabled
      self.repeatYearly = repeatYearly
    }

    public var __variables: Variables? { [
      "title": title,
      "date": date,
      "description": description,
      "link": link,
      "notifyEnabled": notifyEnabled,
      "repeatYearly": repeatYearly
    ] }

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("createEvent", CreateEvent.self, arguments: [
          "title": .variable("title"),
          "date": .variable("date"),
          "description": .variable("description"),
          "link": .variable("link"),
          "notifyEnabled": .variable("notifyEnabled"),
          "repeatYearly": .variable("repeatYearly")
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
          .field("link", String?.self),
          .field("notifyEnabled", Bool.self),
          .field("repeatYearly", Bool.self),
          .field("date", ChoozAPI.Date.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          CreateEventMutation.Data.CreateEvent.self
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