//
//  CatBreed+Mock.swift
//  CatsKit
//
//  Created by Diogo Balseiro on 26/12/2025.
//

import Foundation
import CatsKitDomain

public extension CatBreed {

    // Abyssinian
    static var mockAbyssinian: Self {

        CatBreed(
            id: "abys",
            name: "Abyssinian",
            temperament: "Active, Energetic, Independent, Intelligent, Gentle",
            origin: "Egypt",
            catDescription: "The Abyssinian is easy to care for, and a joy to have in your home. They’re affectionate cats and love both people and other animals.",
            lifeSpan: "14 - 15",
            imageURL: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg",
            favorited: nil)
    }

    // Aegean
    static var mockAegean: Self {
        CatBreed(
            id: "aege",
            name: "Aegean",
            temperament: "Affectionate, Social, Intelligent, Playful, Active",
            origin: "Greece",
            catDescription: "Native to the Greek islands known as the Cyclades in the Aegean Sea, these are natural cats, meaning they developed without humans getting involved in their breeding. As a breed, Aegean Cats are rare, although they are numerous on their home islands. They are generally friendly toward people and can be excellent cats for families with children.",
            lifeSpan: "9 - 12",
            imageURL: "https://cdn2.thecatapi.com/images/ozEvzdVM-.jpg",
            favorited: nil)
    }

    // American Bobtail
    static var mockAmericanBobtail: Self {
        CatBreed(
            id: "abob",
            name: "American Bobtail",
            temperament: "Intelligent, Interactive, Lively, Playful, Sensitive",
            origin: "United States",
            catDescription: "American Bobtails are loving and incredibly intelligent cats possessing a distinctive wild appearance. They are extremely interactive cats that bond with their human family with great devotion.",
            lifeSpan: "11 - 15",
            imageURL: "https://cdn2.thecatapi.com/images/hBXicehMA.jpg",
            favorited: nil)
    }

    // American Curl
    static var mockAmericanCurl: Self {
        CatBreed(
            id: "acur",
            name: "American Curl",
            temperament: "Affectionate, Curious, Intelligent, Interactive, Lively, Playful, Social",
            origin: "United States",
            catDescription: "Distinguished by truly unique ears that curl back in a graceful arc, offering an alert, perky, happily surprised expression, they cause people to break out into a big smile when viewing their first Curl. Curls are very people-oriented, faithful, affectionate soulmates, adjusting remarkably fast to other pets, children, and new situations.",
            lifeSpan: "12 - 16",
            imageURL: "https://cdn2.thecatapi.com/images/xnsqonbjW.jpg",
            favorited: nil)
    }

    // American Shorthair
    static var mockAmericanShorthair: Self {
        CatBreed(
            id: "asho",
            name: "American Shorthair",
            temperament: "Active, Curious, Easy Going, Playful, Calm",
            origin: "United States",
            catDescription: "The American Shorthair is known for its longevity, robust health, good looks, sweet personality, and amiability with children, dogs, and other pets.",
            lifeSpan: "17",
            imageURL: "https://cdn2.thecatapi.com/images/JFPROfGtQ.jpg",
            favorited: nil)
    }

    // American Wirehair
    static var mockAmericanWirehair: Self {
        CatBreed(
            id: "awir",
            name: "American Wirehair",
            temperament: "Affectionate, Curious, Gentle, Intelligent, Interactive, Lively, Loyal, Playful, Sensible, Social",
            origin: "United States",
            catDescription: "The American Wirehair tends to be a calm and tolerant cat who takes life as it comes. His favorite hobby is bird-watching from a sunny windowsill, and his hunting ability will stand you in good stead if insects enter the house.",
            lifeSpan: "14 - 18",
            imageURL: "https://cdn2.thecatapi.com/images/8D--jCd21.jpg",
            favorited: nil)
    }

    // Arabian Mau
    static var mockArabianMau: Self {
        CatBreed(
            id: "amau",
            name: "Arabian Mau",
            temperament: "Affectionate, Agile, Curious, Independent, Playful, Loyal",
            origin: "United Arab Emirates",
            catDescription: "Arabian Mau cats are social and energetic. Due to their energy levels, these cats do best in homes where their owners will be able to provide them with plenty of playtime, attention and interaction from their owners. These kitties are friendly, intelligent, and adaptable, and will even get along well with other pets and children.",
            lifeSpan: "12 - 14",
            imageURL: "https://cdn2.thecatapi.com/images/k71ULYfRr.jpg",
            favorited: nil)
    }

    // Australian Mist
    static var mockAustralianMist: Self {
        CatBreed(
            id: "amis",
            name: "Australian Mist",
            temperament: "Lively, Social, Fun-loving, Relaxed, Affectionate",
            origin: "Australia",
            catDescription: "The Australian Mist thrives on human companionship. Tolerant of even the youngest of children, these friendly felines enjoy playing games and being part of the hustle and bustle of a busy household. They make entertaining companions for people of all ages, and are happy to remain indoors between dusk and dawn or to be wholly indoor pets.",
            lifeSpan: "16",
            imageURL: "https://cdn2.thecatapi.com/images/_6x-3TiCA.jpg",
            favorited: nil)
    }

    // Balinese
    static var mockBalinese: Self {
        CatBreed(
            id: "bali",
            name: "Balinese",
            temperament: "Affectionate, Intelligent, Playful",
            origin: "United States",
            catDescription: "Balinese are curious, outgoing, intelligent cats with excellent communication skills. They are known for their chatty personalities and are always eager to tell you their views on life, love, and what you’ve served them for dinner. ",
            lifeSpan: "10 - 15",
            imageURL: "https://cdn2.thecatapi.com/images/13MkvUreZ.jpg",
            favorited: nil)
    }

    // Bambino
    static var mockBambino: Self {
        CatBreed(
            id: "bamb",
            name: "Bambino",
            temperament: "Affectionate, Lively, Friendly, Intelligent",
            origin: "United States",
            catDescription: "The Bambino is a breed of cat that was created as a cross between the Sphynx and the Munchkin breeds. The Bambino cat has short legs, large upright ears, and is usually hairless. They love to be handled and cuddled up on the laps of their family members.",
            lifeSpan: "12 - 14",
            imageURL: "https://cdn2.thecatapi.com/images/5AdhMjeEu.jpg",
            favorited: nil)
    }
}

public extension CatBreed {

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
}

private extension Date {

    static var epoch: Self {

        Date(timeIntervalSince1970: 0)
    }
}
