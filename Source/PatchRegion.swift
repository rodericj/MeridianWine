//
//  File.swift
//  
//
//  Created by Roderic Campbell on 1/31/21.
//

import Foundation
import Meridian

struct RegionIDParameter: URLParameterKey {
    public typealias DecodeType = String
}

extension ParameterKeys {
    var parentID: RegionIDParameter { .init() }
    var childID: RegionIDParameter { .init() }
}

struct PatchRegion: Responder {
    @EnvironmentObject var database: Database
    @QueryParameter("parent_id") var parentID: String
    @URLParameter(\.childID) var childID

    func execute() throws -> Response {
        print(childID, parentID)
        guard let childUUID = UUID(uuidString: childID),
              let parentUUID = UUID(uuidString: parentID) else {
            throw RegionError.invalidURL
        }
        return try JSON(database.updateParent(parent: parentUUID, child: childUUID)).allowCORS()
    }
}
