//
//  CatGatewayTests.swift
//  catnip
//
//  Created by Diogo Balseiro on 28/12/2025.
//

import Foundation
import Testing
@testable import catnip
import ComposableArchitecture
import CatsKitDomain
import SwiftData
import Combine

@MainActor
@Suite("CatGateway")
struct CatGatewayTests {
    
    private func makeTestCore() -> Core {
        
        Core(environment: .staging(delay: .milliseconds(200)))
    }

    /// Tests that the gateway correctly fetches cat breeds from the API while online.
    ///
    /// This test verifies the complete online data flow:
    /// 1. Initial state has an empty database
    /// 2. First fetch retrieves 10 breeds and caches them
    /// 3. Second fetch retrieves the next 10 breeds and updates pagination
    /// 4. Subsequent fetches serve cached data when requesting previously fetched ranges
    ///
    /// Key behaviors tested:
    /// - Network fetching populates the local cache
    /// - Pagination metadata tracks the current page and limit
    /// - Cached data persists across multiple requests
    /// - Requesting a range that spans multiple pages returns all cached results
    @Test func fetchOnline() async throws {

        let catGateway = makeTestCore().managers.catGateway
        
        // Verify the database starts empty
        var count = try catGateway.modelContainer.mainContext
            .fetchCount(FetchDescriptor<CatBreedManagedModel>())
        #expect(count == 0)
        var pagination = try catGateway.modelContainer.mainContext
            .fetch(FetchDescriptor<PaginationMetadataManagedModel>()).first
        #expect(pagination == nil)
        
        // First fetch: Request 10 breeds (page 0)
        let breeds = try await catGateway.breeds(offset: 0, limit: 10)
        #expect(breeds.count == 10)
        // Verify we got the expected breeds in the correct order, none favorited
        #expect(breeds[0].id == "abys")
        #expect(breeds[0].favorited == nil)
        #expect(breeds[1].id == "aege")
        #expect(breeds[1].favorited == nil)
        #expect(breeds[2].id == "abob")
        #expect(breeds[2].favorited == nil)
        #expect(breeds[3].id == "acur")
        #expect(breeds[3].favorited == nil)
        #expect(breeds[4].id == "asho")
        #expect(breeds[4].favorited == nil)
        #expect(breeds[5].id == "awir")
        #expect(breeds[5].favorited == nil)
        #expect(breeds[6].id == "amau")
        #expect(breeds[6].favorited == nil)
        #expect(breeds[7].id == "amis")
        #expect(breeds[7].favorited == nil)
        #expect(breeds[8].id == "bali")
        #expect(breeds[8].favorited == nil)
        #expect(breeds[9].id == "bamb")
        #expect(breeds[9].favorited == nil)
        
        // Verify pagination metadata was created for page 0
        pagination = try catGateway.modelContainer.mainContext
            .fetch(FetchDescriptor<PaginationMetadataManagedModel>()).first
        #expect(pagination?.page == 0)
        #expect(pagination?.limit == 10)

        // Verify all 10 breeds were cached
        count = try catGateway.modelContainer.mainContext
            .fetchCount(FetchDescriptor<CatBreedManagedModel>())
        #expect(count == 10)

        // Second fetch: Request the next 10 breeds (page 1)
        let moreBreeds = try await catGateway.breeds(offset: 10, limit: 10)
        #expect(moreBreeds.count == 10)
        // Verify the second page has different breeds
        #expect(moreBreeds[0].id == "beng")
        #expect(moreBreeds[0].favorited == nil)
        #expect(moreBreeds[1].id == "birm")
        #expect(moreBreeds[1].favorited == nil)
        #expect(moreBreeds[2].id == "bomb")
        #expect(moreBreeds[2].favorited == nil)
        #expect(moreBreeds[3].id == "bslo")
        #expect(moreBreeds[3].favorited == nil)
        #expect(moreBreeds[4].id == "bsho")
        #expect(moreBreeds[4].favorited == nil)
        #expect(moreBreeds[5].id == "bure")
        #expect(moreBreeds[5].favorited == nil)
        #expect(moreBreeds[6].id == "buri")
        #expect(moreBreeds[6].favorited == nil)
        #expect(moreBreeds[7].id == "cspa")
        #expect(moreBreeds[7].favorited == nil)
        #expect(moreBreeds[8].id == "ctif")
        #expect(moreBreeds[8].favorited == nil)
        #expect(moreBreeds[9].id == "char")
        #expect(moreBreeds[9].favorited == nil)
        
        // Verify pagination metadata was updated to page 1
        pagination = try catGateway.modelContainer.mainContext
            .fetch(FetchDescriptor<PaginationMetadataManagedModel>()).first
        #expect(pagination?.page == 1)
        #expect(pagination?.limit == 10)

        // Verify all 20 breeds are now cached
        count = try catGateway.modelContainer.mainContext
            .fetchCount(FetchDescriptor<CatBreedManagedModel>())
        #expect(count == 20)
        
        // Third fetch: Request all 20 breeds at once (should come from cache)
        let allBreeds = try await catGateway.breeds(offset: 0, limit: 20)
        #expect(allBreeds.count == 20)
        // Verify we get all 20 breeds in order, combining both pages
        #expect(allBreeds[0].id == "abys")
        #expect(allBreeds[0].favorited == nil)
        #expect(allBreeds[1].id == "aege")
        #expect(allBreeds[1].favorited == nil)
        #expect(allBreeds[2].id == "abob")
        #expect(allBreeds[2].favorited == nil)
        #expect(allBreeds[3].id == "acur")
        #expect(allBreeds[3].favorited == nil)
        #expect(allBreeds[4].id == "asho")
        #expect(allBreeds[4].favorited == nil)
        #expect(allBreeds[5].id == "awir")
        #expect(allBreeds[5].favorited == nil)
        #expect(allBreeds[6].id == "amau")
        #expect(allBreeds[6].favorited == nil)
        #expect(allBreeds[7].id == "amis")
        #expect(allBreeds[7].favorited == nil)
        #expect(allBreeds[8].id == "bali")
        #expect(allBreeds[8].favorited == nil)
        #expect(allBreeds[9].id == "bamb")
        #expect(allBreeds[9].favorited == nil)
        #expect(allBreeds[10].id == "beng")
        #expect(allBreeds[10].favorited == nil)
        #expect(allBreeds[11].id == "birm")
        #expect(allBreeds[11].favorited == nil)
        #expect(allBreeds[12].id == "bomb")
        #expect(allBreeds[12].favorited == nil)
        #expect(allBreeds[13].id == "bslo")
        #expect(allBreeds[13].favorited == nil)
        #expect(allBreeds[14].id == "bsho")
        #expect(allBreeds[14].favorited == nil)
        #expect(allBreeds[15].id == "bure")
        #expect(allBreeds[15].favorited == nil)
        #expect(allBreeds[16].id == "buri")
        #expect(allBreeds[16].favorited == nil)
        #expect(allBreeds[17].id == "cspa")
        #expect(allBreeds[17].favorited == nil)
        #expect(allBreeds[18].id == "ctif")
        #expect(allBreeds[18].favorited == nil)
        #expect(allBreeds[19].id == "char")
        #expect(allBreeds[19].favorited == nil)
        
        // Verify pagination metadata remains at page 1 (no new fetch was needed)
        pagination = try catGateway.modelContainer.mainContext
            .fetch(FetchDescriptor<PaginationMetadataManagedModel>()).first
        #expect(pagination?.page == 1)
        #expect(pagination?.limit == 10)
    }
    
    /// Tests that the gateway serves cached data when offline.
    ///
    /// This test verifies offline behavior:
    /// 1. First fetch while online caches 10 breeds
    /// 2. Going offline still allows access to cached breeds
    /// 3. Requesting uncached data while offline returns empty results
    ///
    /// Key behaviors tested:
    /// - Cached data remains accessible when network is unavailable
    /// - The gateway doesn't attempt to fetch data beyond what's cached offline
    /// - Pagination metadata reflects only the cached range
    @Test func fetchOffline() async throws {
        
        let core = makeTestCore()
        let catGateway = core.managers.catGateway
        
        // Verify the database starts empty
        var count = try catGateway.modelContainer.mainContext
            .fetchCount(FetchDescriptor<CatBreedManagedModel>())
        #expect(count == 0)
        var pagination = try catGateway.modelContainer.mainContext
            .fetch(FetchDescriptor<PaginationMetadataManagedModel>()).first
        #expect(pagination == nil)
        
        // Initial fetch while online: Cache 10 breeds
        let breeds = try await catGateway.breeds(offset: 0, limit: 10)
        #expect(breeds.count == 10)
        #expect(breeds[0].id == "abys")
        #expect(breeds[0].favorited == nil)
        #expect(breeds[1].id == "aege")
        #expect(breeds[1].favorited == nil)
        #expect(breeds[2].id == "abob")
        #expect(breeds[2].favorited == nil)
        #expect(breeds[3].id == "acur")
        #expect(breeds[3].favorited == nil)
        #expect(breeds[4].id == "asho")
        #expect(breeds[4].favorited == nil)
        #expect(breeds[5].id == "awir")
        #expect(breeds[5].favorited == nil)
        #expect(breeds[6].id == "amau")
        #expect(breeds[6].favorited == nil)
        #expect(breeds[7].id == "amis")
        #expect(breeds[7].favorited == nil)
        #expect(breeds[8].id == "bali")
        #expect(breeds[8].favorited == nil)
        #expect(breeds[9].id == "bamb")
        #expect(breeds[9].favorited == nil)
        
        // Verify data was cached
        pagination = try catGateway.modelContainer.mainContext
            .fetch(FetchDescriptor<PaginationMetadataManagedModel>()).first
        #expect(pagination?.page == 0)
        #expect(pagination?.limit == 10)

        count = try catGateway.modelContainer.mainContext
            .fetchCount(FetchDescriptor<CatBreedManagedModel>())
        #expect(count == 10)
                
        // Simulate going offline
        let reach = try #require(core.managers.reachability as? Reachability.Mock)
        reach.subject.send(false)
        
        // Fetch cached data while offline: Should return the 10 cached breeds
        let oldBreeds = try await catGateway.breeds(offset: 0, limit: 10)
        #expect(oldBreeds.count == 10)
        // Verify we still get the same cached breeds
        #expect(oldBreeds[0].id == "abys")
        #expect(oldBreeds[0].favorited == nil)
        #expect(oldBreeds[1].id == "aege")
        #expect(oldBreeds[1].favorited == nil)
        #expect(oldBreeds[2].id == "abob")
        #expect(oldBreeds[2].favorited == nil)
        #expect(oldBreeds[3].id == "acur")
        #expect(oldBreeds[3].favorited == nil)
        #expect(oldBreeds[4].id == "asho")
        #expect(oldBreeds[4].favorited == nil)
        #expect(oldBreeds[5].id == "awir")
        #expect(oldBreeds[5].favorited == nil)
        #expect(oldBreeds[6].id == "amau")
        #expect(oldBreeds[6].favorited == nil)
        #expect(oldBreeds[7].id == "amis")
        #expect(oldBreeds[7].favorited == nil)
        #expect(oldBreeds[8].id == "bali")
        #expect(oldBreeds[8].favorited == nil)
        #expect(oldBreeds[9].id == "bamb")
        #expect(oldBreeds[9].favorited == nil)
        
        // Verify pagination and count haven't changed (no new fetch occurred)
        pagination = try catGateway.modelContainer.mainContext
            .fetch(FetchDescriptor<PaginationMetadataManagedModel>()).first
        #expect(pagination?.page == 0)
        #expect(pagination?.limit == 10)

        count = try catGateway.modelContainer.mainContext
            .fetchCount(FetchDescriptor<CatBreedManagedModel>())
        #expect(count == 10)

        // Attempt to fetch uncached data while offline: Should return empty
        let newBreeds = try await catGateway.breeds(offset: 10, limit: 10)
        #expect(newBreeds.count == 0)
    }
    
    @Test func underfetch() async throws {
        
        let core = makeTestCore()
        let catGateway = core.managers.catGateway
        
        // Verify the database starts empty
        var count = try catGateway.modelContainer.mainContext
            .fetchCount(FetchDescriptor<CatBreedManagedModel>())
        #expect(count == 0)
        var pagination = try catGateway.modelContainer.mainContext
            .fetch(FetchDescriptor<PaginationMetadataManagedModel>()).first
        #expect(pagination == nil)
        
        let breeds = try await catGateway.breeds(offset: 0, limit: 50)
        #expect(breeds.count == 10)
        #expect(breeds[0].id == "abys")
        #expect(breeds[0].favorited == nil)
        #expect(breeds[1].id == "aege")
        #expect(breeds[1].favorited == nil)
        #expect(breeds[2].id == "abob")
        #expect(breeds[2].favorited == nil)
        #expect(breeds[3].id == "acur")
        #expect(breeds[3].favorited == nil)
        #expect(breeds[4].id == "asho")
        #expect(breeds[4].favorited == nil)
        #expect(breeds[5].id == "awir")
        #expect(breeds[5].favorited == nil)
        #expect(breeds[6].id == "amau")
        #expect(breeds[6].favorited == nil)
        #expect(breeds[7].id == "amis")
        #expect(breeds[7].favorited == nil)
        #expect(breeds[8].id == "bali")
        #expect(breeds[8].favorited == nil)
        #expect(breeds[9].id == "bamb")
        #expect(breeds[9].favorited == nil)
        
        // Verify data was cached
        pagination = try catGateway.modelContainer.mainContext
            .fetch(FetchDescriptor<PaginationMetadataManagedModel>()).first
        #expect(pagination?.page == 0)
        #expect(pagination?.limit == 10)

        count = try catGateway.modelContainer.mainContext
            .fetchCount(FetchDescriptor<CatBreedManagedModel>())
        #expect(count == 10)
    }
    
    @Test func overfetch() async throws {
        
        let core = makeTestCore()
        let catGateway = core.managers.catGateway
        
        // Verify the database starts empty
        var count = try catGateway.modelContainer.mainContext
            .fetchCount(FetchDescriptor<CatBreedManagedModel>())
        #expect(count == 0)
        var pagination = try catGateway.modelContainer.mainContext
            .fetch(FetchDescriptor<PaginationMetadataManagedModel>()).first
        #expect(pagination == nil)
        
        let breeds = try await catGateway.breeds(offset: 0, limit: 5)
        #expect(breeds.count == 5)
        #expect(breeds[0].id == "abys")
        #expect(breeds[0].favorited == nil)
        #expect(breeds[1].id == "aege")
        #expect(breeds[1].favorited == nil)
        #expect(breeds[2].id == "abob")
        #expect(breeds[2].favorited == nil)
        #expect(breeds[3].id == "acur")
        #expect(breeds[3].favorited == nil)
        #expect(breeds[4].id == "asho")
        #expect(breeds[4].favorited == nil)
        
        // Verify data was cached
        pagination = try catGateway.modelContainer.mainContext
            .fetch(FetchDescriptor<PaginationMetadataManagedModel>()).first
        #expect(pagination?.page == 0)
        #expect(pagination?.limit == 10)

        count = try catGateway.modelContainer.mainContext
            .fetchCount(FetchDescriptor<CatBreedManagedModel>())
        #expect(count == 10)
    }
    
    @Test func favoriting() async throws {
        
        let core = makeTestCore()
        let catGateway = core.managers.catGateway
        
        // Verify the database starts empty
        let count = try catGateway.modelContainer.mainContext
            .fetchCount(FetchDescriptor<CatBreedManagedModel>())
        #expect(count == 0)
        
        var favorites = try catGateway.allFavoriteBreeds()
        #expect(favorites.count == 0)
        
        var breeds = try await catGateway.breeds(offset: 0, limit: 10)
        #expect(breeds[0].id == "abys")
        #expect(breeds[0].favorited == nil)
        #expect(breeds[1].id == "aege")
        #expect(breeds[1].favorited == nil)
        #expect(breeds[2].id == "abob")
        #expect(breeds[2].favorited == nil)
        #expect(breeds[3].id == "acur")
        #expect(breeds[3].favorited == nil)
        #expect(breeds[4].id == "asho")
        #expect(breeds[4].favorited == nil)
        #expect(breeds[5].id == "awir")
        #expect(breeds[5].favorited == nil)
        #expect(breeds[6].id == "amau")
        #expect(breeds[6].favorited == nil)
        #expect(breeds[7].id == "amis")
        #expect(breeds[7].favorited == nil)
        #expect(breeds[8].id == "bali")
        #expect(breeds[8].favorited == nil)
        #expect(breeds[9].id == "bamb")
        #expect(breeds[9].favorited == nil)
        
        var favoritedBreed = try catGateway.favoriteBreed(breeds[0], favoritedAt: Date())
        #expect(favoritedBreed.favorited != nil)
        favoritedBreed = try catGateway.favoriteBreed(breeds[5], favoritedAt: Date())
        #expect(favoritedBreed.favorited != nil)
        favoritedBreed = try catGateway.favoriteBreed(breeds[9], favoritedAt: Date())
        #expect(favoritedBreed.favorited != nil)

        favorites = try catGateway.allFavoriteBreeds()
        #expect(favorites.count == 3)
        
        breeds = try await catGateway.breeds(offset: 0, limit: 10)
        #expect(breeds[0].id == "abys")
        #expect(breeds[0].favorited != nil)
        #expect(breeds[1].id == "aege")
        #expect(breeds[1].favorited == nil)
        #expect(breeds[2].id == "abob")
        #expect(breeds[2].favorited == nil)
        #expect(breeds[3].id == "acur")
        #expect(breeds[3].favorited == nil)
        #expect(breeds[4].id == "asho")
        #expect(breeds[4].favorited == nil)
        #expect(breeds[5].id == "awir")
        #expect(breeds[5].favorited != nil)
        #expect(breeds[6].id == "amau")
        #expect(breeds[6].favorited == nil)
        #expect(breeds[7].id == "amis")
        #expect(breeds[7].favorited == nil)
        #expect(breeds[8].id == "bali")
        #expect(breeds[8].favorited == nil)
        #expect(breeds[9].id == "bamb")
        #expect(breeds[9].favorited != nil)
        
        var unfavoritedBreed = try catGateway.unfavoriteBreed(breeds[0])
        #expect(unfavoritedBreed.favorited == nil)
        
        favorites = try catGateway.allFavoriteBreeds()
        #expect(favorites.count == 2)
        
        breeds = try await catGateway.breeds(offset: 0, limit: 10)
        #expect(breeds[0].id == "abys")
        #expect(breeds[0].favorited == nil)
        #expect(breeds[1].id == "aege")
        #expect(breeds[1].favorited == nil)
        #expect(breeds[2].id == "abob")
        #expect(breeds[2].favorited == nil)
        #expect(breeds[3].id == "acur")
        #expect(breeds[3].favorited == nil)
        #expect(breeds[4].id == "asho")
        #expect(breeds[4].favorited == nil)
        #expect(breeds[5].id == "awir")
        #expect(breeds[5].favorited != nil)
        #expect(breeds[6].id == "amau")
        #expect(breeds[6].favorited == nil)
        #expect(breeds[7].id == "amis")
        #expect(breeds[7].favorited == nil)
        #expect(breeds[8].id == "bali")
        #expect(breeds[8].favorited == nil)
        #expect(breeds[9].id == "bamb")
        #expect(breeds[9].favorited != nil)
        
        // Simulate going offline
        let reach = try #require(core.managers.reachability as? Reachability.Mock)
        reach.subject.send(false)

        unfavoritedBreed = try catGateway.unfavoriteBreed(breeds[5])
        #expect(unfavoritedBreed.favorited == nil)
        
        favorites = try catGateway.allFavoriteBreeds()
        #expect(favorites.count == 1)
        
        breeds = try await catGateway.breeds(offset: 0, limit: 10)
        #expect(breeds[0].id == "abys")
        #expect(breeds[0].favorited == nil)
        #expect(breeds[1].id == "aege")
        #expect(breeds[1].favorited == nil)
        #expect(breeds[2].id == "abob")
        #expect(breeds[2].favorited == nil)
        #expect(breeds[3].id == "acur")
        #expect(breeds[3].favorited == nil)
        #expect(breeds[4].id == "asho")
        #expect(breeds[4].favorited == nil)
        #expect(breeds[5].id == "awir")
        #expect(breeds[5].favorited == nil)
        #expect(breeds[6].id == "amau")
        #expect(breeds[6].favorited == nil)
        #expect(breeds[7].id == "amis")
        #expect(breeds[7].favorited == nil)
        #expect(breeds[8].id == "bali")
        #expect(breeds[8].favorited == nil)
        #expect(breeds[9].id == "bamb")
        #expect(breeds[9].favorited != nil)
    }
    
    @Test func search() async throws {
        
        let core = makeTestCore()
        let catGateway = core.managers.catGateway
        
        // Verify the database starts empty
        var count = try catGateway.modelContainer.mainContext
            .fetchCount(FetchDescriptor<CatBreedManagedModel>())
        #expect(count == 0)

        // Simulate going offline
        let reach = try #require(core.managers.reachability as? Reachability.Mock)
        reach.subject.send(false)

        var searchResults = try await catGateway.searchBreeds(query: "rag")
        #expect(searchResults.count == 0)
        
        count = try catGateway.modelContainer.mainContext
            .fetchCount(FetchDescriptor<CatBreedManagedModel>())
        #expect(count == 0)

        // Simulate going online
        reach.subject.send(true)
        
        searchResults = try await catGateway.searchBreeds(query: "rag")
        #expect(searchResults.count == 3)
        
        count = try catGateway.modelContainer.mainContext
            .fetchCount(FetchDescriptor<CatBreedManagedModel>())
        #expect(count == 3)
        
        // Simulate going offline
        reach.subject.send(false)
        
        searchResults = try await catGateway.searchBreeds(query: "rag")
        #expect(searchResults.count == 3)
        
        count = try catGateway.modelContainer.mainContext
            .fetchCount(FetchDescriptor<CatBreedManagedModel>())
        #expect(count == 3)
    }
    
    @Test func duplicateInserts() async throws {
        
        let core = makeTestCore()
        let catGateway = try #require(core.managers.catGateway as? CatGateway)

        // Verify the database starts empty
        var count = try catGateway.modelContainer.mainContext
            .fetchCount(FetchDescriptor<CatBreedManagedModel>())
        #expect(count == 0)
                
        let breeds = try await catGateway.breeds(offset: 0, limit: 10)
        
        // Verify all 10 breeds were cached
        count = try catGateway.modelContainer.mainContext
            .fetchCount(FetchDescriptor<CatBreedManagedModel>())
        #expect(count == 10)

        try catGateway.insert(breeds)
        
        // Verify all 10 breeds were cached
        count = try catGateway.modelContainer.mainContext
            .fetchCount(FetchDescriptor<CatBreedManagedModel>())
        #expect(count == 10)
        
        try catGateway.insert(breeds)
        
        // Verify all 10 breeds were cached
        count = try catGateway.modelContainer.mainContext
            .fetchCount(FetchDescriptor<CatBreedManagedModel>())
        #expect(count == 10)
    }
}
