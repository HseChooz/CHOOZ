// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

protocol ChoozAPI_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == ChoozAPI.SchemaMetadata {}

protocol ChoozAPI_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == ChoozAPI.SchemaMetadata {}

protocol ChoozAPI_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == ChoozAPI.SchemaMetadata {}

protocol ChoozAPI_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == ChoozAPI.SchemaMetadata {}

extension ChoozAPI {
  typealias SelectionSet = ChoozAPI_SelectionSet

  typealias InlineFragment = ChoozAPI_InlineFragment

  typealias MutableSelectionSet = ChoozAPI_MutableSelectionSet

  typealias MutableInlineFragment = ChoozAPI_MutableInlineFragment

  enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
      switch typename {
      case "AuthPayload": return ChoozAPI.Objects.AuthPayload
      case "Mutation": return ChoozAPI.Objects.Mutation
      case "UserType": return ChoozAPI.Objects.UserType
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}