//
//  CatBreedDTO+Mock.swift
//  CatsKit
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation
import CatsKitService

public extension CatBreedDTO {

    // MARK: - Abyssinian
    static var mockAbyssinian: Self {
        CatBreedDTO(
            id: "abys",
            name: "Abyssinian",
            temperament: "Active, Energetic, Independent, Intelligent, Gentle",
            origin: "Egypt",
            catDescription: "The Abyssinian is easy to care for, and a joy to have in your home. They’re affectionate cats and love both people and other animals.",
            lifeSpan: "14 - 15",
            imageURL: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg"
        )
    }

    // MARK: - Aegean
    static var mockAegean: Self {
        CatBreedDTO(
            id: "aege",
            name: "Aegean",
            temperament: "Affectionate, Social, Intelligent, Playful, Active",
            origin: "Greece",
            catDescription: "Native to the Greek islands known as the Cyclades in the Aegean Sea, these are natural cats, meaning they developed without humans getting involved in their breeding. As a breed, Aegean Cats are rare, although they are numerous on their home islands. They are generally friendly toward people and can be excellent cats for families with children.",
            lifeSpan: "9 - 12",
            imageURL: "https://cdn2.thecatapi.com/images/ozEvzdVM-.jpg"
        )
    }

    // MARK: - American Bobtail
    static var mockAmericanBobtail: Self {
        CatBreedDTO(
            id: "abob",
            name: "American Bobtail",
            temperament: "Intelligent, Interactive, Lively, Playful, Sensitive",
            origin: "United States",
            catDescription: "American Bobtails are loving and incredibly intelligent cats possessing a distinctive wild appearance. They are extremely interactive cats that bond with their human family with great devotion.",
            lifeSpan: "11 - 15",
            imageURL: "https://cdn2.thecatapi.com/images/hBXicehMA.jpg"
        )
    }

    // MARK: - American Curl
    static var mockAmericanCurl: Self {
        CatBreedDTO(
            id: "acur",
            name: "American Curl",
            temperament: "Affectionate, Curious, Intelligent, Interactive, Lively, Playful, Social",
            origin: "United States",
            catDescription: "Distinguished by truly unique ears that curl back in a graceful arc, offering an alert, perky, happily surprised expression, they cause people to break out into a big smile when viewing their first Curl. Curls are very people-oriented, faithful, affectionate soulmates, adjusting remarkably fast to other pets, children, and new situations.",
            lifeSpan: "12 - 16",
            imageURL: "https://cdn2.thecatapi.com/images/xnsqonbjW.jpg"
        )
    }

    // MARK: - American Shorthair
    static var mockAmericanShorthair: Self {
        CatBreedDTO(
            id: "asho",
            name: "American Shorthair",
            temperament: "Active, Curious, Easy Going, Playful, Calm",
            origin: "United States",
            catDescription: "The American Shorthair is known for its longevity, robust health, good looks, sweet personality, and amiability with children, dogs, and other pets.",
            lifeSpan: "15 - 17",
            imageURL: "https://cdn2.thecatapi.com/images/JFPROfGtQ.jpg"
        )
    }

    // MARK: - American Wirehair
    static var mockAmericanWirehair: Self {
        CatBreedDTO(
            id: "awir",
            name: "American Wirehair",
            temperament: "Affectionate, Curious, Gentle, Intelligent, Interactive, Lively, Loyal, Playful, Sensible, Social",
            origin: "United States",
            catDescription: "The American Wirehair tends to be a calm and tolerant cat who takes life as it comes. His favorite hobby is bird-watching from a sunny windowsill, and his hunting ability will stand you in good stead if insects enter the house.",
            lifeSpan: "14 - 18",
            imageURL: "https://cdn2.thecatapi.com/images/8D--jCd21.jpg"
        )
    }

    // MARK: - Arabian Mau
    static var mockArabianMau: Self {
        CatBreedDTO(
            id: "amau",
            name: "Arabian Mau",
            temperament: "Affectionate, Agile, Curious, Independent, Playful, Loyal",
            origin: "United Arab Emirates",
            catDescription: "Arabian Mau cats are social and energetic. Due to their energy levels, these cats do best in homes where their owners will be able to provide them with plenty of playtime, attention and interaction from their owners. These kitties are friendly, intelligent, and adaptable, and will even get along well with other pets and children.",
            lifeSpan: "12 - 14",
            imageURL: "https://cdn2.thecatapi.com/images/k71ULYfRr.jpg"
        )
    }

    // MARK: - Australian Mist
    static var mockAustralianMist: Self {
        CatBreedDTO(
            id: "amis",
            name: "Australian Mist",
            temperament: "Lively, Social, Fun-loving, Relaxed, Affectionate",
            origin: "Australia",
            catDescription: "The Australian Mist thrives on human companionship. Tolerant of even the youngest of children, these friendly felines enjoy playing games and being part of the hustle and bustle of a busy household. They make entertaining companions for people of all ages, and are happy to remain indoors between dusk and dawn or to be wholly indoor pets.",
            lifeSpan: "12 - 16",
            imageURL: "https://cdn2.thecatapi.com/images/_6x-3TiCA.jpg"
        )
    }

    // MARK: - Balinese
    static var mockBalinese: Self {
        CatBreedDTO(
            id: "bali",
            name: "Balinese",
            temperament: "Affectionate, Intelligent, Playful",
            origin: "United States",
            catDescription: "Balinese are curious, outgoing, intelligent cats with excellent communication skills. They are known for their chatty personalities and are always eager to tell you their views on life, love, and what you’ve served them for dinner. ",
            lifeSpan: "10 - 15",
            imageURL: "https://cdn2.thecatapi.com/images/13MkvUreZ.jpg"
        )
    }

    // MARK: - Bambino
    static var mockBambino: Self {
        CatBreedDTO(
            id: "bamb",
            name: "Bambino",
            temperament: "Affectionate, Lively, Friendly, Intelligent",
            origin: "United States",
            catDescription: "The Bambino is a breed of cat that was created as a cross between the Sphynx and the Munchkin breeds. The Bambino cat has short legs, large upright ears, and is usually hairless. They love to be handled and cuddled up on the laps of their family members.",
            lifeSpan: "12 - 14",
            imageURL: "https://cdn2.thecatapi.com/images/5AdhMjeEu.jpg"
        )
    }

    // MARK: - Ragamuffin
    static var mockRagamuffin: Self {
        CatBreedDTO(
            id: "raga",
            name: "Ragamuffin",
            temperament: "Affectionate, Friendly, Gentle, Calm",
            origin: "United States",
            catDescription: "The Ragamuffin is calm, even tempered and gets along well with all family members. Changes in routine generally do not upset her. She is an ideal companion for those in apartments, and with children due to her patient nature.",
            lifeSpan: "12 - 16",
            imageURL: "https://cdn2.thecatapi.com/images/SMuZx-bFM.jpg"
        )
    }

    // MARK: - Ragdoll
    static var mockRagdoll: Self {
        CatBreedDTO(
            id: "ragd",
            name: "Ragdoll",
            temperament: "Affectionate, Friendly, Gentle, Quiet, Easygoing",
            origin: "United States",
            catDescription: "Ragdolls love their people, greeting them at the door, following them around the house, and leaping into a lap or snuggling in bed whenever given the chance. They are the epitome of a lap cat, enjoy being carried and collapsing into the arms of anyone who holds them.",
            lifeSpan: "12 - 17",
            imageURL: "https://cdn2.thecatapi.com/images/oGefY4YoG.jpg"
        )
    }

    // MARK: - Dragon Li
    static var mockDragonLi: Self {
        CatBreedDTO(
            id: "lihu",
            name: "Dragon Li",
            temperament: "Intelligent, Friendly, Gentle, Loving, Loyal",
            origin: "China",
            catDescription: "The Dragon Li is loyal, but not particularly affectionate. They are known to be very intelligent, and their natural breed status means that they're very active. She is is gentle with people, and has a reputation as a talented hunter of rats and other vermin.",
            lifeSpan: "12 - 15",
            imageURL: "https://cdn2.thecatapi.com/images/BQMSld0A0.jpg"
        )
    }
}

public extension CatBreedDTO {

    static var allMocks: [Self] {
        [
        mockAbyssinian,
        mockAegean,
        mockAmericanBobtail,
        mockAmericanCurl,
        mockAmericanShorthair,
        mockAmericanWirehair,
        mockArabianMau,
        mockAustralianMist,
        mockBalinese,
        mockBambino
        ]
    }

    static var searchRagMocks: [Self] {
        [
        mockRagamuffin,
        mockRagdoll,
        mockDragonLi
        ]
    }
}

public extension CatBreedDTO {

    static func mockData(page: Int) -> Data? {

        guard let breeds = Bundle.module.url(forResource: "cat-breeds-page-\(page)",
                                             withExtension: "json") else {

            return nil
        }

        return try? Data(contentsOf: breeds)
    }

    static func mockDataSearch() -> Data? {

        guard let breeds = Bundle.module.url(forResource: "search-rag",
                                             withExtension: "json") else {

            return nil
        }

        return try? Data(contentsOf: breeds)
    }
}
