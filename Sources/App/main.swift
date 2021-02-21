import Foundation
import Backtrace
import Meridian
import MeridianWine

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
let configuration = URLSessionConfiguration.default

Server(errorRenderer: BasicErrorRenderer())
    .group(prefix: "/region", errorRenderer: JSONErrorRenderer()) {

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
    .register({
        BundledFiles(bundle: .module)
    })
    .environmentObject(Database())
    .environmentObject(URLSession(configuration: configuration))
    .listen()
