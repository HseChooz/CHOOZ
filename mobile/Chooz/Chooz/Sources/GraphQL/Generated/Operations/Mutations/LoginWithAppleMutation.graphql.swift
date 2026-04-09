// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class LoginWithAppleMutation: GraphQLMutation {
    static let operationName: String = "LoginWithApple"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation LoginWithApple($identityToken: String!) { loginWithApple(identityToken: $identityToken) { __typename accessToken refreshToken user { __typename id email username } } }"#
      ))

    public var identityToken: String

    public init(identityToken: String) {
      self.identityToken = identityToken
    }

    public var __variables: Variables? { ["identityToken": identityToken] }

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("loginWithApple", LoginWithApple.self, arguments: ["identityToken": .variable("identityToken")]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        LoginWithAppleMutation.Data.self
      ] }

      var loginWithApple: LoginWithApple { __data["loginWithApple"] }

      /// LoginWithApple
      ///
      /// Parent Type: `AuthPayload`
      struct LoginWithApple: ChoozAPI.SelectionSet {
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
          LoginWithAppleMutation.Data.LoginWithApple.self
        ] }

        var accessToken: String { __data["accessToken"] }
        var refreshToken: String { __data["refreshToken"] }
        var user: User { __data["user"] }

        /// LoginWithApple.User
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
            LoginWithAppleMutation.Data.LoginWithApple.User.self
          ] }

          var id: ChoozAPI.ID { __data["id"] }
          var email: String { __data["email"] }
          var username: String { __data["username"] }
        }
      }
    }
  }

}