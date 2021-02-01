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

Backtrace.install()

Server(errorRenderer: BasicErrorRenderer())
    .group(prefix: "/region", errorRenderer: JSONErrorRenderer()) {

        GetRegions()
            .on(.get(.root))
        
        PostRegion()
            .on(.post(.root))
        
        PatchRegion()
            .on(.patch("/\(\.childID)"))

        GetRegionGeoJson()
            .on(.get("/\(\.id)/geojson"))
    }
    .environmentObject(Database())
    .environmentObject(URLSession())
    .listen()
