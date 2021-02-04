//
//  main.swift
//  MeridianDemo
//
//

import Foundation
import Backtrace
import Meridian

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

let configuration = URLSessionConfiguration.default
Backtrace.install()

Server(errorRenderer: BasicErrorRenderer())
    .group(prefix: "/region", errorRenderer: JSONErrorRenderer()) {

        GetRegions()
            .on(.get(.root))
        
        PostRegion()
            .on(.post(.root))
       
        DeleteRegion()
            .on(.delete("/\(\.childID)"))
        
        PatchRegion()
            .on(.patch("/\(\.childID)"))

        GetRegionGeoJson()
            .on(.get("/\(\.id)/geojson"))
    }
    .environmentObject(Database())
    .environmentObject(URLSession(configuration: configuration))
    .listen()
