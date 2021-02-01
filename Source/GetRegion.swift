//
//  File.swift
//  
//
//  Created by Roderic Campbell on 1/27/21.
//

import Foundation
import GEOSwift
import Meridian

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct GetRegions: Responder {
    @EnvironmentObject var database: Database
    
    func execute() throws -> Response {
        try JSON(database.fetchAllInvoices())
            .allowCORS()
    }
}

struct GetRegionGeoJson: Responder {
    @EnvironmentObject var database: Database
    
    @URLParameter(\.id) var id
    
    func execute() throws -> Response {
        // get this one from the database
        guard let uuid = UUID(uuidString: id) else {
            throw RegionError.invalidURL
        }
        guard let region = try database.fetchRegion(uuid: uuid) else {
            throw RegionError.regionNotFound
        }

        guard let url = URLComponents.nominatimURL(id: String(region.osmID)) else {
            throw RegionError.invalidURL
        }
        let request = URLRequest(url: url)
        let (data, _) = try URLSession.shared.send(request: request)
        
        let decoder = JSONDecoder()
        
        let nomanatimTypeCheck =  try decoder.decode(NomanatimResponseTypeCheck.self, from: data).geometry.type
        
        let geometry: Encodable
        switch nomanatimTypeCheck {
        case "MultiPolygon":
            geometry = try decoder.decode(NomanatimResponseMultiPolygon.self, from: data).geometry
        case "Polygon":
            geometry =  try decoder.decode(NomanatimResponsePolygon.self, from: data).geometry
            
        default:
            throw RegionError.unknownGeometryType
        }
        let encoder = JSONEncoder()
        let encodableBox = AnyEncodable(value: geometry)
        let encodedGeoJson = try encoder.encode(encodableBox)
        let recodedGeoJson = try decoder.decode(GeoJSON.self, from: encodedGeoJson)
        return JSON(recodedGeoJson).allowCORS()
        
    }
}
