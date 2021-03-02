//
//  File.swift
//  
//
//  Created by Roderic Campbell on 1/27/21.
//

import Foundation
import SwiftgreSQL
import Meridian

struct Status: Codable {
    let status: String
}

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

struct JsonResponse<T: Encodable>: Encodable {
    let result: T
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
    
    func deleteRegion(region: UUID) throws -> Status {
        try connection.execute("DELETE from osmregion WHERE id = $1 RETURNING *;",
                                      [region.uuidString])
        return Status(status: "OK")
    }
    
    func update(parent: String?, title: String?, child: UUID) throws -> JsonResponse<Region>? {
        if let parent = parent, let parentUUID = UUID(uuidString: parent), let title = title {
            return try connection.execute("UPDATE osmregion SET parent_id = $1, title = $2 WHERE id = $3 RETURNING *;",
                                      [parentUUID.uuidString, title, child.uuidString])
                .decode(DatabaseRegion.self).map { JsonResponse(result: Region($0)) }
                .first
        } else if let parent = parent, let parentUUID = UUID(uuidString: parent) {
            return try connection.execute("UPDATE osmregion SET parent_id = $1 WHERE id = $2 RETURNING *;",
                                          [parentUUID.uuidString, child.uuidString])
                .decode(DatabaseRegion.self).map { JsonResponse(result: Region($0)) }
                .first
        } else if let title = title {
            return try connection.execute("UPDATE osmregion SET title = $1 WHERE id = $2 RETURNING *;",
                                          [title, child.uuidString])
                .decode(DatabaseRegion.self).map { JsonResponse(result: Region($0)) }
                .first
        } else {
            return nil
        }
    }
    
    func insertRegion(nominatim: NominatimResponseTypeCheck) throws -> JsonResponse<Region>? {
        let uuid = UUID()
        let queryTemplate = "INSERT INTO osmregion VALUES($1, $2, $3) RETURNING *;"
        do {
            let ret = try connection
                .execute(queryTemplate, [uuid.uuidString, nominatim.localname, nominatim.osmID])
                .decode(DatabaseRegion.self).map { JsonResponse(result: Region($0)) }
            print(ret)
            return ret.first
        } catch {
            if let pgError = error as? PostgreSQLError {
                throw pgError
            }
            print(error)
            throw error
        }
    }
    
   
    func fetchRegion(uuid: UUID) throws -> Region? {
        let query = "SELECT * FROM osmregion WHERE id = $1"
        return try connection.execute(query, [uuid.uuidString])
            .decode(DatabaseRegion.self).compactMap { Region($0)}.first
    }
}

extension Database {
    func fetchAllRegions() throws -> JsonResponse<[Region]>?  {
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
        return JsonResponse(result: idToRegionMapping.filter { dict in
            idsToSend.contains(dict.key)
        }.map { $0.value})
    }
}

