//
//  File.swift
//  
//
//  Created by Roderic Campbell on 1/31/21.
//

import Meridian
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct PostRegion: Responder {
    @EnvironmentObject var database: Database
    @QueryParameter("osmid") var osmID: Int
    
    func execute() throws -> Response {
        let fetch = try fetchFromNominatim(regionID: osmID)
        return try JSON(database.insertRegion(nominatim: fetch)).allowCORS()
    }
    
    private func fetchFromNominatim(regionID: Int) throws -> NominatimResponseTypeCheck {

        guard let url = URLComponents.nominatimURL(id: String(osmID)) else {
            throw RegionError.invalidURL
        }
        
        let request = URLRequest(url: url)
        let (data, _) = try URLSession.shared.send(request: request)
        let decoder = JSONDecoder()

        do {
            return try decoder.decode(NominatimResponseTypeCheck.self, from: data)
        } catch {
            let errorResponse = try? decoder.decode(NominatimErrorResponse.self, from: data)
            print(errorResponse)
            print(error)
            throw error
        }
    }
}
