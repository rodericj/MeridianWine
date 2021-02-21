//
//  File.swift
//  
//
//  Created by Roderic Campbell on 1/31/21.
//

import Foundation
import Meridian

public struct RegionIDParameter: URLParameterKey {
    public typealias DecodeType = String
}

extension ParameterKeys {
    public var parentID: RegionIDParameter { .init() }
    public var childID: RegionIDParameter { .init() }
}

public struct PatchRegion: Responder {
    @EnvironmentObject var database: Database
    @QueryParameter("parent_id") var parentID: String
    @URLParameter(\.childID) var childID
    public init() {}

    public func execute() throws -> Response {
        print(childID, parentID)
        guard let childUUID = UUID(uuidString: childID),
              let parentUUID = UUID(uuidString: parentID) else {
            throw RegionError.invalidURL
        }
        return try JSON(database.updateParent(parent: parentUUID, child: childUUID)).allowCORS()
    }
}
