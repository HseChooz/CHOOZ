// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class MeQuery: GraphQLQuery {
    static let operationName: String = "Me"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query Me { me { __typename id email username firstName lastName } }"#
      ))

    public init() {}

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("me", Me?.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        MeQuery.Data.self
      ] }

      var me: Me? { __data["me"] }

      /// Me
      ///
      /// Parent Type: `UserType`
      struct Me: ChoozAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.UserType }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", ChoozAPI.ID.self),
          .field("email", String.self),
          .field("username", String.self),
          .field("firstName", String.self),
          .field("lastName", String.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          MeQuery.Data.Me.self
        ] }

        var id: ChoozAPI.ID { __data["id"] }
        var email: String { __data["email"] }
        var username: String { __data["username"] }
        var firstName: String { __data["firstName"] }
        var lastName: String { __data["lastName"] }
      }
    }
  }

}