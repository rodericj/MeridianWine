//
//  File.swift
//  
//
//  Created by Roderic Campbell on 1/27/21.
//

import Foundation
import SwiftgreSQL
import Meridian

struct DatabaseRegion: Codable, Equatable {
    let id: UUID
    let osmID: Int
    let title: String
    let parentID: UUID?
    
    enum CodingKeys: String, CodingKey {
        case osmID, id, title
        case parentID = "parent_id"
    }
}

class Region: Encodable {
    let id: UUID
    let title: String
    let osmID: Int
    var children: [Region]
    init(_ dbRegion: DatabaseRegion) {
        id = dbRegion.id
        title = dbRegion.title
        osmID = dbRegion.osmID
        children = []
    }
}

public final class Database {
    public init() { }
    let connection = try! Connection(connInfo: "postgres://roderic@localhost:5432/regions")
    func fetchRegion(uuid: UUID) throws -> Region? {
        let query = "SELECT * FROM osmregion where id = '\(uuid)'"
        print(query)
        return try connection.execute(query)
            .decode(DatabaseRegion.self).compactMap { Region($0)}.first

    }
    func fetchAllInvoices() throws -> [Region] {
        let databaseResponse = try connection.execute("SELECT * FROM osmregion")
            .decode(DatabaseRegion.self)
        
        // Setup the mapping
        let idToRegionMapping = databaseResponse.reduce([UUID: Region]()) { intermediate, dbRegion -> [UUID: Region] in
            var intermediate = intermediate
            intermediate[dbRegion.id] = Region(dbRegion)
            return intermediate
        }
        
        // iterate over the response, for each, append it to it's parent in the mapping
        databaseResponse.forEach { dbRegion in
            if let parentID = dbRegion.parentID,
               let regionObject = idToRegionMapping[dbRegion.id],
               let parent = idToRegionMapping[parentID] {
                parent.children.append(regionObject)
            }
        }
                
        // iterate over the response find IDs of all items with nil parents
        let idsToSend = databaseResponse
            .filter { $0.parentID == nil }
            .map { $0.id }
            
        // itereate one last time to only send the parentless ones
        return idToRegionMapping.filter { dict in
            idsToSend.contains(dict.key)
        }.map { $0.value}
        
    }
}
