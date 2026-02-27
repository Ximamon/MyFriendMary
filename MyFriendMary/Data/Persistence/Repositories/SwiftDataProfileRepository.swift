import Foundation
import SwiftData

@MainActor
final class SwiftDataProfileRepository: ProfileRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func getProfile() async throws -> UserProfile {
        if let model = try fetchStoredProfile() {
            return ProfileMapper.toDomain(model)
        }

        let profileModel = SDUserProfile()
        context.insert(profileModel)
        try save()
        return ProfileMapper.toDomain(profileModel)
    }

    func saveProfile(_ profile: UserProfile) async throws {
        let model = try fetchStoredProfile() ?? SDUserProfile()
        if model.modelContext == nil {
            context.insert(model)
        }

        ProfileMapper.apply(profile, to: model)
        try save()
    }

    private func fetchStoredProfile() throws -> SDUserProfile? {
        let profileID = SDUserProfile.singletonID
        var descriptor = FetchDescriptor<SDUserProfile>(
            predicate: #Predicate { model in
                model.id == profileID
            }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    private func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
