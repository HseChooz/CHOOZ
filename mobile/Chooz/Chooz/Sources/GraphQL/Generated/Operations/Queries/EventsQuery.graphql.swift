// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class EventsQuery: GraphQLQuery {
    static let operationName: String = "Events"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Events { events { __typename id title description link notifyEnabled repeatYearly date } }"#
      ))

    public init() {}

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("events", [Event].self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        EventsQuery.Data.self
      ] }

      var events: [Event] { __data["events"] }

      /// Event
      ///
      /// Parent Type: `EventType`
      struct Event: ChoozAPI.SelectionSet {
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
          EventsQuery.Data.Event.self
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