// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ChoozAPI {
  class CreateWishItemImageUploadMutation: GraphQLMutation {
    static let operationName: String = "CreateWishItemImageUpload"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation CreateWishItemImageUpload($id: ID!, $filename: String!, $contentType: String! = "image/png") { createWishItemImageUpload( id: $id filename: $filename contentType: $contentType ) { __typename key uploadUrl } }"#
      ))

    public var id: ID
    public var filename: String
    public var contentType: String

    public init(
      id: ID,
      filename: String,
      contentType: String = "image/png"
    ) {
      self.id = id
      self.filename = filename
      self.contentType = contentType
    }

    public var __variables: Variables? { [
      "id": id,
      "filename": filename,
      "contentType": contentType
    ] }

    struct Data: ChoozAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("createWishItemImageUpload", CreateWishItemImageUpload.self, arguments: [
          "id": .variable("id"),
          "filename": .variable("filename"),
          "contentType": .variable("contentType")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        CreateWishItemImageUploadMutation.Data.self
      ] }

      var createWishItemImageUpload: CreateWishItemImageUpload { __data["createWishItemImageUpload"] }

      /// CreateWishItemImageUpload
      ///
      /// Parent Type: `PresignedUpload`
      struct CreateWishItemImageUpload: ChoozAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { ChoozAPI.Objects.PresignedUpload }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("key", String.self),
          .field("uploadUrl", String.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          CreateWishItemImageUploadMutation.Data.CreateWishItemImageUpload.self
        ] }

        var key: String { __data["key"] }
        var uploadUrl: String { __data["uploadUrl"] }
      }
    }
  }

}