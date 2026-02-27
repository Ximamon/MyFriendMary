import Foundation

protocol ProfileRepository {
    func getProfile() async throws -> UserProfile
    func saveProfile(_ profile: UserProfile) async throws
}
