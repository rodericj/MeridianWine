import Foundation
import HTML
import Meridian

struct HTMLEncodingError: Error { }

extension HTML.Node: Response {
    public func body() throws -> Data {
        var string = ""
        self.write(to: &string)
        guard let data = string.data(using: .utf8) else {
            throw HTMLEncodingError()
        }
        return data
    }
}
