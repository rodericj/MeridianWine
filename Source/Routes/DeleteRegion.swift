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
    var regionID: RegionIDParameter { .init() }
}

struct DeleteRegion: Responder {
    @EnvironmentObject var database: Database
    @URLParameter(\.regionID) var regionID

    func execute() throws -> Response {
        guard let regionUUID = UUID(uuidString: regionID) else {
            throw DeleteError.invalidUUIDParameter
        }
        return try JSON(database.deleteRegion(region: regionUUID))
            .allowCORS()
    }
}
