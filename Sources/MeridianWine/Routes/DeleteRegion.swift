//
//  File.swift
//  
//
//  Created by Roderic Campbell on 2/3/21.
//

import Foundation
import Meridian

enum DeleteError: Error {
    case invalidUUIDParameter
}

extension ParameterKeys {
    public var regionID: RegionIDParameter { .init() }
}

public struct DeleteRegion: Responder {
    @EnvironmentObject var database: Database
    @URLParameter(\.regionID) public var regionID
    public init() {}

    public func execute() throws -> Response {
        guard let regionUUID = UUID(uuidString: regionID) else {
            throw DeleteError.invalidUUIDParameter
        }
        return try JSON(database.deleteRegion(region: regionUUID))
            .allowCORS()
    }
}
