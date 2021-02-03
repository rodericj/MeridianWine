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
    let connection: Connection = {
        guard let databaseURL = ProcessInfo.processInfo.environment["DATABASE_URL"] else {
            fatalError("databaseURL is not set. Please set the environment variable")
        }
        do {
            return try Connection(connInfo: databaseURL)
        } catch {
            fatalError(error.localizedDescription)
        }
    }()
    
    func updateParent(parent: UUID, child: UUID) throws -> Region? {
        let query = "UPDATE osmregion SET parent_id = '\(parent)' WHERE id = '\(child)' RETURNING *;"
        return try connection.execute(query).decode(DatabaseRegion.self).map { Region($0) }.first
    }
    
    func insertRegion(nominatim: NominatimResponseTypeCheck) throws -> Region? {
        let uuid = UUID()
        let queryTemplate = "INSERT INTO osmregion VALUES($1, $2, $3) RETURNING *;"
        return try connection
            .execute(queryTemplate, [uuid.uuidString, nominatim.localname, nominatim.osmID])
            .decode(DatabaseRegion.self).map { Region($0) }.first
    }
   
    func fetchRegion(uuid: UUID) throws -> Region? {
        let query = "SELECT * FROM osmregion WHERE id = '\(uuid.uuidString)'"
        return try connection.execute(query)
            .decode(DatabaseRegion.self).compactMap { Region($0)}.first
    }
}

extension Database {
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

