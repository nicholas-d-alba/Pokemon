//
//  PokemonEntity+CoreDataProperties.swift
//  PokeDex
//
//  Created by Nicholas Alba on 6/23/21.
//
//

import Foundation
import CoreData


extension PokemonEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PokemonEntity> {
        return NSFetchRequest<PokemonEntity>(entityName: "PokemonEntity")
    }

    @NSManaged public var name: String?

}

extension PokemonEntity : Identifiable {

}
