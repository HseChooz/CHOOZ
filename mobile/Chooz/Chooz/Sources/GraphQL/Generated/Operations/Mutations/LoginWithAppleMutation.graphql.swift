// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class LoginWithAppleMutation: GraphQLMutation {
    static let operationName: String = "LoginWithApple"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation LoginWithApple($identityToken: String!, $firstName: String, $lastName: String) { loginWithApple( identityToken: $identityToken firstName: $firstName lastName: $lastName ) { __typename accessToken refreshToken user { __typename id email username firstName lastName } } }"#
      ))

    public var identityToken: String
    public var firstName: GraphQLNullable<String>
    public var lastName: GraphQLNullable<String>

    public init(
      identityToken: String,
      firstName: GraphQLNullable<String>,
      lastName: GraphQLNullable<String>
    ) {
      self.identityToken = identityToken
      self.firstName = firstName
      self.lastName = lastName
    }

    public var __variables: Variables? { [
      "identityToken": identityToken,
      "firstName": firstName,
      "lastName": lastName
    ] }

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("loginWithApple", LoginWithApple.self, arguments: [
          "identityToken": .variable("identityToken"),
          "firstName": .variable("firstName"),
          "lastName": .variable("lastName")
        ]),
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
            .field("firstName", String.self),
            .field("lastName", String.self),
          ] }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            LoginWithAppleMutation.Data.LoginWithApple.User.self
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

}