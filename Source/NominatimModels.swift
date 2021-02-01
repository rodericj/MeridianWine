//
//  File.swift
//  
//
//  Created by Roderic Campbell on 1/27/21.
//

import Foundation


struct NominatimResponseTypeCheck: Decodable {
    let osmID: Int
    let geometry: Geometry
    let localname: String
    struct Geometry: Decodable {
        let type: String
    }
    enum CodingKeys: String, CodingKey {
        case osmID = "osm_id"
        case geometry, localname
    }
}

enum RegionError: Error {
    case regionNotFound
    case invalidURL
    case unknownShapeDefinition
    case unknownGeometryType
}

struct NominatimResponseMultiPolygon: Decodable {
    let osmID: Int
    let localname: String
    let geometry: Geometry
    struct Geometry: Codable, Hashable {
        let coordinates: [[[[Double]]]] // 4 parens
        let type: String
    }
    enum CodingKeys: String, CodingKey {
           case osmID = "osm_id"
           case localname
        case geometry
       }
}

struct NominatimResponsePolygon: Decodable {
    let osmID: Int
    let localname: String
    let geometry: Geometry
    struct Geometry: Codable {
        let coordinates: [[[Double]]] // only 3 parens
        let type: String
    }
    enum CodingKeys: String, CodingKey {
           case osmID = "osm_id"
           case localname
        case geometry
       }
}
