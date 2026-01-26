// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class LoginWithGoogleMutation: GraphQLMutation {
    static let operationName: String = "LoginWithGoogle"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation LoginWithGoogle($idToken: String!) { loginWithGoogle(idToken: $idToken) { __typename accessToken refreshToken user { __typename id email username } } }"#
      ))

    public var idToken: String

    public init(idToken: String) {
      self.idToken = idToken
    }

    public var __variables: Variables? { ["idToken": idToken] }

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("loginWithGoogle", LoginWithGoogle.self, arguments: ["idToken": .variable("idToken")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        LoginWithGoogleMutation.Data.self
      ] }

      var loginWithGoogle: LoginWithGoogle { __data["loginWithGoogle"] }

      /// LoginWithGoogle
      ///
      /// Parent Type: `AuthPayload`
      struct LoginWithGoogle: ChoozAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.AuthPayload }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("accessToken", String.self),
          .field("refreshToken", String.self),
          .field("user", User.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          LoginWithGoogleMutation.Data.LoginWithGoogle.self
        ] }

        var accessToken: String { __data["accessToken"] }
        var refreshToken: String { __data["refreshToken"] }
        var user: User { __data["user"] }

        /// LoginWithGoogle.User
        ///
        /// Parent Type: `UserType`
        struct User: ChoozAPI.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.UserType }
          static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", ChoozAPI.ID.self),
            .field("email", String.self),
            .field("username", String.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            LoginWithGoogleMutation.Data.LoginWithGoogle.User.self
          ] }

          var id: ChoozAPI.ID { __data["id"] }
          var email: String { __data["email"] }
          var username: String { __data["username"] }
        }
      }
    }
  }

}