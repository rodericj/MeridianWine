//
//  File.swift
//  
//
//  Created by Roderic Campbell on 1/27/21.
//

import Foundation


struct NomanatimResponseTypeCheck: Decodable {
    let osmID: Int
    let geometry: Geometry
    struct Geometry: Decodable {
        let type: String
    }
    enum CodingKeys: String, CodingKey {
        case osmID = "osm_id"
        case geometry
    }
}

enum RegionError: Error {
    case regionNotFound
    case invalidURL
    case unknownShapeDefinition
    case unknownGeometryType
}

struct NomanatimResponseMultiPolygon: Decodable {
    let osmID: Int
    let localname: String
    let geometry: Geometry
    struct Geometry: Codable, Hashable {
        let coordinates: [[[[Double]]]]
        let type: String
    }
    enum CodingKeys: String, CodingKey {
           case osmID = "osm_id"
           case localname
        case geometry
       }
}

struct NomanatimResponsePolygon: Decodable {
    let osmID: Int
    let localname: String
    let geometry: Geometry
    struct Geometry: Codable {
        let coordinates: [[[Double]]]
        let type: String
    }
    enum CodingKeys: String, CodingKey {
           case osmID = "osm_id"
           case localname
        case geometry
       }
}
