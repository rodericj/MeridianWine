//
//  main.swift
//  MeridianDemo
//
//

import Foundation
import Backtrace
import Meridian

Backtrace.install()

Server(errorRenderer: BasicErrorRenderer())
    .group(prefix: "/region", errorRenderer: JSONErrorRenderer()) {

        GetRegions()
            .on(.get(.root))
        
        PostRegions()
            .on(.post(.root))

        GetRegionGeoJson()
            .on(.get("/\(\.id)/geojson"))
    }
    .environmentObject(Database())
    .environmentObject(URLSession())
    .listen()
