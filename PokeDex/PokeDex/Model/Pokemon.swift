//
//  Pokemon.swift
//  PokeDex
//
//  Created by Nicholas Alba on 6/22/21.
//

import Foundation
import UIKit

struct PokemonDecodable: Decodable {
    let name: String?
    let id: Int?
    let height: Int?
    let weight: Int?
    let sprites: Sprites?
}

struct Sprites: Decodable {
    let front_default: String?
}

class Pokemon: Equatable {
    
    init?(from pokemonDecodable: PokemonDecodable, with data: Data) {
        guard let unwrappedName =  pokemonDecodable.name?.asTitle(),
              let spriteURLString = pokemonDecodable.sprites?.front_default,
              let unwrappedID = pokemonDecodable.id else {
            print("Incomplete pokemon details for pokemonDecodable")
            return nil
        }
        guard let spriteURL = URL(string: spriteURLString),
              let spriteData = try? Data(contentsOf: spriteURL),
              let spriteImage = UIImage(data: spriteData) else {
            print("Could not load sprite from \(spriteURLString)")
            return nil
        }
        guard let officialArtworkURLString = getOfficialArtworkURLString(from: data),
              let officialArtworkURL = URL(string: officialArtworkURLString),
              let officialArtworkData = try? Data(contentsOf: officialArtworkURL),
              let officialArtworkImage = UIImage(data: officialArtworkData) else {
            print("Could not load official artwork.")
            return nil
        }
        name = unwrappedName
        id = unwrappedID
        sprite = spriteImage
        artwork = officialArtworkImage
        height = pokemonDecodable.height
        weight = pokemonDecodable.weight
    }
    
    static func == (lhs: Pokemon, rhs: Pokemon) -> Bool {
        return lhs.id == rhs.id
    }
    
    let name: String
    let id: Int
    let height: Int?
    let weight: Int?
    let sprite: UIImage
    let artwork: UIImage
}

func getOfficialArtworkURLString(from data: Data) -> String? {
    let pokemonJSON = try? JSONSerialization.jsonObject(with: data, options: [])
    let pokemonDictionary = pokemonJSON as? [String: Any]
    let spritesDictionary = pokemonDictionary?["sprites"] as? [String: Any]
    let otherArtworkDictionary = spritesDictionary?["other"] as? [String: Any]
    let officialArtworkDictionary = otherArtworkDictionary?["official-artwork"] as? [String: Any]
    let officialArtworkURLString = officialArtworkDictionary?["front_default"] as? String
    return officialArtworkURLString
}
