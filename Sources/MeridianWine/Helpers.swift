//
//  File.swift
//  
//
//  Created by Roderic Campbell on 1/27/21.
//

import Foundation
import Meridian

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct IDParameter: URLParameterKey {
    public typealias DecodeType = String
}

extension ParameterKeys {
    public var id: IDParameter {
        IDParameter()
    }
}

struct AnyEncodable: Encodable {
    let value: Encodable

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try value.encode(to: &container)
    }
}

extension Encodable {
    func encode(to container: inout SingleValueEncodingContainer) throws {
        try container.encode(self)
    }
}

extension URLSession {
    public func send(request: URLRequest) throws -> (Data, HTTPURLResponse) {
        var outerError: Error?
        var result: (Data, HTTPURLResponse)?
        let semaphore = DispatchSemaphore(value: 0)
        dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                result = (data, response)
            } else {
                outerError = error
            }
            semaphore.signal()
        }).resume()
        semaphore.wait()
        if let error = outerError {
            throw error
        } else if let result = result {
            return result
        } else {
            fatalError("Something went horribly wrong.")
        }
    }
}


extension URLComponents {
    static func nominatimURL(id: String) -> URL? {
        var regionDetailURI = URLComponents(string: "https://nominatim.openstreetmap.org/details.php")
        regionDetailURI?.queryItems = [
            URLQueryItem(name: "osmtype", value: "R"),
            URLQueryItem(name: "osmid", value: id),
            URLQueryItem(name: "class", value: "boundary"),
            URLQueryItem(name: "addressdetails", value: "1"),
            URLQueryItem(name: "hierarchy", value: "1"),
            URLQueryItem(name: "group_hierarchy", value: "1"),
            URLQueryItem(name: "polygon_geojson", value: "1"),
            URLQueryItem(name: "format", value: "json")
        ]
        return regionDetailURI?.url
    }
}
