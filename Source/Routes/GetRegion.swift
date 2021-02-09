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
        try JSON(database.fetchAllRegions())
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
        
        let nominatimTypeCheck = try decoder.decode(NominatimResponseTypeCheck.self, from: data).geometry.type
        
        switch nominatimTypeCheck {
        case "MultiPolygon":
            let geometry = try decoder.decode(NominatimResponseMultiPolygon.self, from: data).geometry
            let wrapper = GeoJsonWrapperMultiPolygon(type: "FeatureCollection",
                                                     features: [.init(type: "Feature",
                                                                      properties: [:],
                                                                      geometry: geometry)])
            return JSON(wrapper).allowCORS()
        case "Polygon":
            let geometry = try decoder.decode(NominatimResponsePolygon.self, from: data).geometry
            let wrapper = GeoJsonWrapperPolygon(type: "FeatureCollection",
                                                features: [.init(type: "Feature",
                                                                 properties: [:],
                                                                 geometry: geometry)]
                                               )
            return JSON(wrapper).allowCORS()
            
        default:
            throw RegionError.unknownGeometryType
        }
    }
}

struct GeoJsonWrapperMultiPolygon: Codable {
    struct WrapperFeature: Codable {
        let type: String
        let properties: [String: String]?
        let geometry: NominatimResponseMultiPolygon.Geometry
    }
    let type: String
    let features: [WrapperFeature]
}

struct SingleWrappedFeature: Codable {
    let type: String
    let properties: [String: String]?
    let geometry: NominatimResponsePolygon.Geometry
}

struct GeoJsonWrapperPolygon: Codable {
    struct WrapperFeature: Codable {
        let type: String
        let properties: [String: String]
        let geometry: NominatimResponsePolygon.Geometry
    }
    let type: String
    let features: [WrapperFeature]
}


struct SimpleGeoJsonWrapper: Codable {
    let geometry: NominatimResponseMultiPolygon.Geometry
}

