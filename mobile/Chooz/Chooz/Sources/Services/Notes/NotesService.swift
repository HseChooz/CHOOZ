import Foundation
import Apollo

protocol NotesService {
    func fetchNotes(onlyFavorites: Bool) async throws -> [NotePayload]
    func createNote(_ model: NoteFormModel) async throws -> NotePayload
    func updateNote(
        id: String,
        title: String?,
        description: String?,
        link: String?,
        isFavorite: Bool?
    ) async throws -> NotePayload
    func updateNoteFavorite(id: String, isFavorite: Bool) async throws -> NotePayload
    func deleteNote(id: String) async throws
}

final class NotesServiceImpl: NotesService {

    // MARK: - Init

    init(apolloClient: ApolloClient) {
        self.apolloClient = apolloClient
    }

    // MARK: - Internal Methods

    func fetchNotes(onlyFavorites: Bool) async throws -> [NotePayload] {
        let result: Result<[NotePayload], Error> = await withCheckedContinuation { continuation in
            apolloClient.fetch(
                query: ChoozAPI.NotesQuery(onlyFavorites: onlyFavorites),
                cachePolicy: .fetchIgnoringCacheCompletely
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    let notes = graphQLResult.data?.notes.map(Self.mapNote) ?? []
                    continuation.resume(returning: .success(notes))

                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }

        return try result.get()
    }

    func createNote(_ model: NoteFormModel) async throws -> NotePayload {
        let result: Result<NotePayload, Error> = await withCheckedContinuation { continuation in
            apolloClient.perform(
                mutation: ChoozAPI.CreateNoteMutation(
                    title: model.title,
                    description: model.description,
                    link: model.link,
                    isFavorite: false
                )
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    if let note = graphQLResult.data?.createNote {
                        continuation.resume(returning: .success(Self.mapNote(note)))
                    } else {
                        let message = graphQLResult.errors?.first?.message ?? "Не удалось создать заметку"
                        continuation.resume(returning: .failure(Self.makeError(message: message)))
                    }

                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }

        return try result.get()
    }

    func updateNoteFavorite(id: String, isFavorite: Bool) async throws -> NotePayload {
        try await updateNote(
            id: id,
            title: nil,
            description: nil,
            link: nil,
            isFavorite: isFavorite
        )
    }

    func updateNote(
        id: String,
        title: String?,
        description: String?,
        link: String?,
        isFavorite: Bool?
    ) async throws -> NotePayload {
        let result: Result<NotePayload, Error> = await withCheckedContinuation { continuation in
            apolloClient.perform(
                mutation: ChoozAPI.UpdateNoteMutation(
                    id: id,
                    title: title.map { .some($0) } ?? .null,
                    description: description.map { .some($0) } ?? .null,
                    link: link.map { .some($0) } ?? .null,
                    isFavorite: isFavorite.map { .some($0) } ?? .null
                )
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    if let note = graphQLResult.data?.updateNote {
                        continuation.resume(returning: .success(Self.mapNote(note)))
                    } else {
                        let message = graphQLResult.errors?.first?.message ?? "Не удалось обновить заметку"
                        continuation.resume(returning: .failure(Self.makeError(message: message)))
                    }

                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }

        return try result.get()
    }

    func deleteNote(id: String) async throws {
        let result: Result<Bool, Error> = await withCheckedContinuation { continuation in
            apolloClient.perform(
                mutation: ChoozAPI.DeleteNoteMutation(id: id)
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    if graphQLResult.data?.deleteNote == true {
                        continuation.resume(returning: .success(true))
                    } else {
                        let message = graphQLResult.errors?.first?.message ?? "Не удалось удалить заметку"
                        continuation.resume(returning: .failure(Self.makeError(message: message)))
                    }

                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }

        let _ = try result.get()
    }

    // MARK: - Private Properties

    private let apolloClient: ApolloClient

    // MARK: - Private Methods

    private static func mapNote(_ note: ChoozAPI.NotesQuery.Data.Note) -> NotePayload {
        NotePayload(
            id: note.id,
            title: note.title,
            description: note.description,
            link: note.link.flatMap(URL.init(string:)),
            isFavorite: note.isFavorite,
            createdAt: note.createdAt,
            updatedAt: note.updatedAt
        )
    }

    private static func mapNote(_ note: ChoozAPI.CreateNoteMutation.Data.CreateNote) -> NotePayload {
        NotePayload(
            id: note.id,
            title: note.title,
            description: note.description,
            link: note.link.flatMap(URL.init(string:)),
            isFavorite: note.isFavorite,
            createdAt: note.createdAt,
            updatedAt: note.updatedAt
        )
    }

    private static func mapNote(_ note: ChoozAPI.UpdateNoteMutation.Data.UpdateNote) -> NotePayload {
        NotePayload(
            id: note.id,
            title: note.title,
            description: note.description,
            link: note.link.flatMap(URL.init(string:)),
            isFavorite: note.isFavorite,
            createdAt: note.createdAt,
            updatedAt: note.updatedAt
        )
    }

    private static func makeError(message: String) -> NSError {
        NSError(
            domain: "NotesService",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
    }

}
