import Foundation
import Backtrace
import Meridian
import MeridianWine

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
let configuration = URLSessionConfiguration.default

Backtrace.install()

Server(errorRenderer: BasicErrorRenderer())
    .register({
        GetRegionHTML()
            .on(.get(.root))
        
        BundledFiles(bundle: .module)
    })
    .group(prefix: "/region", errorRenderer: JSONErrorRenderer()) {

        GetRegions()
            .on(.get(.root))
        
        GetRegions()
            .on(.get(.root))
        
        PostRegion()
            .on(.post(.root))
       
        DeleteRegion()
            .on(.delete("/\(\.regionID)"))
        
        PatchRegion()
            .on(.patch("/\(\.childID)"))
        
        GetRegionGeoJson()
            .on(.get("/\(\.id)/geojson"))
        
    }
    
    .environmentObject(Database())
    .environmentObject(URLSession(configuration: configuration))
    .listen()
