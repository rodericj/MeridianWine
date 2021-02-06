import Meridian
import SwiftgreSQL

extension PostgreSQLError: ReportableError {
    public var statusCode: StatusCode {
        StatusCode(code: code.hashValue, name: identifier)
    }
    
    public var message: String {
        if code == .uniqueViolation {
            return "This item already exists"
        }
        return localizedDescription
    }
    
    public var externallyVisible: Bool {
        true
    }
}

enum RegionError: ReportableError {
    var statusCode: StatusCode {
        switch self {
        case .regionNotFound:
            return StatusCode(code: 1, name: "regionNotFound")
        case .invalidURL:
            return StatusCode(code: 2, name: "invalidURL")
        case .unknownGeometryType:
            return StatusCode(code: 4, name: "unknownGeometryType")
        case .invalidParameter:
            return StatusCode(code: 3, name: "invalidParameter")
        }
    }
    
    var message: String {
        switch self {
        
        case .regionNotFound:
            return "Region not found"
        case .invalidURL:
            return "Invalid URL"
        case .invalidParameter:
            return "The parameter passed in was invalid"
        case .unknownGeometryType:
            return "The GeoJson returned was not a Polygon or Multipolygon"
        }
    }
    
    var externallyVisible: Bool {
        switch self {
        
        case .regionNotFound:
            return true
        case .invalidURL:
            return true
        case .invalidParameter:
            return true
        case .unknownGeometryType:
            return true
        }
    }
    
    case regionNotFound
    case invalidURL
    case invalidParameter
    case unknownGeometryType
}
