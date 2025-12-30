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
            lifeSpan: "15 - 17",
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
            lifeSpan: "12 - 16",
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

    // Bengal
    static var mockBengal: Self {
        CatBreed(
            id: "beng",
            name: "Bengal",
            temperament: "Alert, Agile, Energetic, Demanding, Intelligent",
            origin: "United States",
            catDescription: "Bengals are a lot of fun to live with, but they're definitely not the cat for everyone, or for first-time cat owners. Extremely intelligent, curious and active, they demand a lot of interaction and woe betide the owner who doesn't provide it.",
            lifeSpan: "12 - 15",
            imageURL: "https://cdn2.thecatapi.com/images/O3btzLlsO.png",
            favorited: nil)
    }

    // Birman
    static var mockBirman: Self {
        CatBreed(
            id: "birm",
            name: "Birman",
            temperament: "Affectionate, Active, Gentle, Social",
            origin: "France",
            catDescription: "The Birman is a docile, quiet cat who loves people and will follow them from room to room. Expect the Birman to want to be involved in what you’re doing. He communicates in a soft voice, mainly to remind you that perhaps it’s time for dinner or maybe for a nice cuddle on the sofa. He enjoys being held and will relax in your arms like a furry baby.",
            lifeSpan: "14 - 15",
            imageURL: "https://cdn2.thecatapi.com/images/HOrX5gwLS.jpg",
            favorited: nil)
    }

    // Bombay
    static var mockBombay: Self {
        CatBreed(
            id: "bomb",
            name: "Bombay",
            temperament: "Affectionate, Dependent, Gentle, Intelligent, Playful",
            origin: "United States",
            catDescription: "The the golden eyes and the shiny black coa of the Bopmbay is absolutely striking. Likely to bond most with one family member, the Bombay will follow you from room to room and will almost always have something to say about what you are doing, loving attention and to be carried around, often on his caregiver's shoulder.",
            lifeSpan: "12 - 16",
            imageURL: "https://cdn2.thecatapi.com/images/5iYq9NmT1.jpg",
            favorited: nil)
    }

    // British Longhair
    static var mockBritishLonghair: Self {
        CatBreed(
            id: "bslo",
            name: "British Longhair",
            temperament: "Affectionate, Easy Going, Independent, Intelligent, Loyal, Social",
            origin: "United Kingdom",
            catDescription: "The British Longhair is a very laid-back relaxed cat, often perceived to be very independent although they will enjoy the company of an equally relaxed and likeminded cat. They are an affectionate breed, but very much on their own terms and tend to prefer to choose to come and sit with their owners rather than being picked up.",
            lifeSpan: "12 - 14",
            imageURL: "https://cdn2.thecatapi.com/images/7isAO4Cav.jpg",
            favorited: nil)
    }

    // British Shorthair
    static var mockBritishShorthair: Self {
        CatBreed(
            id: "bsho",
            name: "British Shorthair",
            temperament: "Affectionate, Easy Going, Gentle, Loyal, Patient, calm",
            origin: "United Kingdom",
            catDescription: "The British Shorthair is a very pleasant cat to have as a companion, ans is easy going and placid. The British is a fiercely loyal, loving cat and will attach herself to every one of her family members. While loving to play, she doesn't need hourly attention. If she is in the mood to play, she will find someone and bring a toy to that person. The British also plays well by herself, and thus is a good companion for single people.",
            lifeSpan: "12 - 17",
            imageURL: "https://cdn2.thecatapi.com/images/s4wQfYoEk.jpg",
            favorited: nil)
    }

    // Burmese
    static var mockBurmese: Self {
        CatBreed(
            id: "bure",
            name: "Burmese",
            temperament: "Curious, Intelligent, Gentle, Social, Interactive, Playful, Lively",
            origin: "Burma",
            catDescription: "Burmese love being with people, playing with them, and keeping them entertained. They crave close physical contact and abhor an empty lap. They will follow their humans from room to room, and sleep in bed with them, preferably under the covers, cuddled as close as possible. At play, they will turn around to see if their human is watching and being entertained by their crazy antics.",
            lifeSpan: "15 - 16",
            imageURL: "https://cdn2.thecatapi.com/images/4lXnnfxac.jpg",
            favorited: nil)
    }

    // Burmilla
    static var mockBurmilla: Self {
        CatBreed(
            id: "buri",
            name: "Burmilla",
            temperament: "Easy Going, Friendly, Intelligent, Lively, Playful, Social",
            origin: "United Kingdom",
            catDescription: "The Burmilla is a fairly placid cat. She tends to be an easy cat to get along with, requiring minimal care. The Burmilla is affectionate and sweet and makes a good companion, the Burmilla is an ideal companion to while away a lonely evening. Loyal, devoted, and affectionate, this cat will stay by its owner, always keeping them company.",
            lifeSpan: "10 - 15",
            imageURL: "https://cdn2.thecatapi.com/images/jvg3XfEdC.jpg",
            favorited: nil)
    }

    // California Spangled
    static var mockCaliforniaSpangled: Self {
        CatBreed(
            id: "cspa",
            name: "California Spangled",
            temperament: "Affectionate, Curious, Intelligent, Loyal, Social",
            origin: "United States",
            catDescription: "Perhaps the only thing about the California spangled cat that isn’t wild-like is its personality. Known to be affectionate, gentle and sociable, this breed enjoys spending a great deal of time with its owners. They are very playful, often choosing to perch in high locations and show off their acrobatic skills.",
            lifeSpan: "10 - 14",
            imageURL: "https://cdn2.thecatapi.com/images/B1ERTmgph.jpg",
            favorited: nil)
    }

    // Chantilly-Tiffany
    static var mockChantillyTiffany: Self {
        CatBreed(
            id: "ctif",
            name: "Chantilly-Tiffany",
            temperament: "Affectionate, Demanding, Interactive, Loyal",
            origin: "United States",
            catDescription: "The Chantilly is a devoted companion and prefers company to being left alone. While the Chantilly is not demanding, she will \"chirp\" and \"talk\" as if having a conversation. This breed is affectionate, with a sweet temperament. It can stay still for extended periods, happily lounging in the lap of its loved one. This quality makes the Tiffany an ideal traveling companion, and an ideal house companion for senior citizens and the physically handicapped.",
            lifeSpan: "14 - 16",
            imageURL: "https://cdn2.thecatapi.com/images/TR-5nAd_S.jpg",
            favorited: nil)
    }

    // Chartreux
    static var mockChartreux: Self {
        CatBreed(
            id: "char",
            name: "Chartreux",
            temperament: "Affectionate, Loyal, Intelligent, Social, Lively, Playful",
            origin: "France",
            catDescription: "The Chartreux is generally silent but communicative. Short play sessions, mixed with naps and meals are their perfect day. Whilst appreciating any attention you give them, they are not demanding, content instead to follow you around devotedly, sleep on your bed and snuggle with you if you’re not feeling well.",
            lifeSpan: "12 - 15",
            imageURL: "https://cdn2.thecatapi.com/images/j6oFGLpRG.jpg",
            favorited: nil)
    }
    
    // Ragamuffin
    static var mockRagamuffin: Self {
        CatBreed(
            id: "raga",
            name: "Ragamuffin",
            temperament: "Affectionate, Friendly, Gentle, Calm",
            origin: "United States",
            catDescription: "The Ragamuffin is calm, even tempered and gets along well with all family members. Changes in routine generally do not upset her. She is an ideal companion for those in apartments, and with children due to her patient nature.",
            lifeSpan: "12 - 16",
            imageURL: "https://cdn2.thecatapi.com/images/SMuZx-bFM.jpg",
            favorited: nil)
    }

    // Ragdoll
    static var mockRagdoll: Self {
        CatBreed(
            id: "ragd",
            name: "Ragdoll",
            temperament: "Affectionate, Friendly, Gentle, Quiet, Easygoing",
            origin: "United States",
            catDescription: "Ragdolls love their people, greeting them at the door, following them around the house, and leaping into a lap or snuggling in bed whenever given the chance. They are the epitome of a lap cat, enjoy being carried and collapsing into the arms of anyone who holds them.",
            lifeSpan: "12 - 17",
            imageURL: "https://cdn2.thecatapi.com/images/oGefY4YoG.jpg",
            favorited: nil)
    }

    // Dragon Li
    static var mockDragonLi: Self {
        CatBreed(
            id: "lihu",
            name: "Dragon Li",
            temperament: "Intelligent, Friendly, Gentle, Loving, Loyal",
            origin: "China",
            catDescription: "The Dragon Li is loyal, but not particularly affectionate. They are known to be very intelligent, and their natural breed status means that they're very active. She is is gentle with people, and has a reputation as a talented hunter of rats and other vermin.",
            lifeSpan: "12 - 15",
            imageURL: "https://cdn2.thecatapi.com/images/BQMSld0A0.jpg",
            favorited: nil)
    }
}

public extension CatBreed {

    static var allMocksPage0: [Self] {
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

    static var allMocksPage1: [Self] {
        [
        mockBengal,
        mockBirman,
        mockBombay,
        mockBritishLonghair,
        mockBritishShorthair,
        mockBurmese,
        mockBurmilla,
        mockCaliforniaSpangled,
        mockChantillyTiffany,
        mockChartreux
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

private extension Date {

    static var epoch: Self {

        Date(timeIntervalSince1970: 0)
    }
}
