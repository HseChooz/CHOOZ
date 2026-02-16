// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class LoginWithYandexMutation: GraphQLMutation {
    static let operationName: String = "LoginWithYandex"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation LoginWithYandex($oauthToken: String!) { loginWithYandex(oauthToken: $oauthToken) { __typename accessToken refreshToken user { __typename id email username } } }"#
      ))

    public var oauthToken: String

    public init(oauthToken: String) {
      self.oauthToken = oauthToken
    }

    public var __variables: Variables? { ["oauthToken": oauthToken] }

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("loginWithYandex", LoginWithYandex.self, arguments: ["oauthToken": .variable("oauthToken")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        LoginWithYandexMutation.Data.self
      ] }

      var loginWithYandex: LoginWithYandex { __data["loginWithYandex"] }

      /// LoginWithYandex
      ///
      /// Parent Type: `AuthPayload`
      struct LoginWithYandex: ChoozAPI.SelectionSet {
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
          LoginWithYandexMutation.Data.LoginWithYandex.self
        ] }

        var accessToken: String { __data["accessToken"] }
        var refreshToken: String { __data["refreshToken"] }
        var user: User { __data["user"] }

        /// LoginWithYandex.User
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
            LoginWithYandexMutation.Data.LoginWithYandex.User.self
          ] }

          var id: ChoozAPI.ID { __data["id"] }
          var email: String { __data["email"] }
          var username: String { __data["username"] }
        }
      }
    }
  }

}