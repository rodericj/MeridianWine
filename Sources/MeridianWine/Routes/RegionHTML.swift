import Foundation
import HTML
import Meridian

public struct GetRegionHTML: Responder {
    @EnvironmentObject var database: Database

    public init() {}
    
    private func createRegionCard(region: Region, parentID: String) -> Node {
        return div(class: "card") {
            createRegionCard(
                name: region.title,
                uuid: region.id,
                collapseTargetName: "collapse-\(region.id.uuidString)",
                headingID: "heading-\(region.id.uuidString)",
                hasChildren: !region.children.isEmpty
            )
            div(
                class: "collapse show",
                id: "collapse-\(region.id.uuidString)",
                customAttributes: [
                    "aria-labelledby": "heading-\(region.id.uuidString)",
                    "data-parent": "#regionTable",
                ]) {
                region.children.map { region in
                    createRegionCard(region: region, parentID: region.id.uuidString)
                }
            }
            
        }
    }
    
    private func createRegionCard(name: String, uuid: UUID, collapseTargetName: String, headingID: String, hasChildren: Bool) -> Node {
        return div(class: "d-flex justify-content-between bd-highlight", id: headingID) {
            button(class: "btn btn-link",
                   type: "button",
                   customAttributes: [
                    "onClick": "updateMap('\(uuid.uuidString)');"
                   ]
            ) {
                name
            }
            if hasChildren {
                button(class: "btn btn-link",
                       type: "button",
                       customAttributes: [
                        "data-toggle": "collapse",
                        "data-target" : "#\(collapseTargetName)",
                        "aria-expanded" : "true",
                        "aria-controls" : collapseTargetName,
                       ]
                ) {
                    ">"
                }
            }
        }
    }
    public func execute() throws -> Response {
        let regionsResponse = try database.fetchAllRegions()
        let regions: [Region]
        switch regionsResponse {        
        case .none:
            regions = []
        case .some(let regionsResponse):
            regions = regionsResponse.result
        }
        return html(lang: "en-US") {
            title{ "Wine Regions" }
            header {
                script(src: "https://code.jquery.com/jquery-3.5.1.min.js")
                script(src: "https://api.mapbox.com/mapbox.js/plugins/turf/v2.0.2/turf.min.js")
                script(src: "https://api.mapbox.com/mapbox-gl-js/v2.1.1/mapbox-gl.js")
                "<link href='https://api.mapbox.com/mapbox-gl-js/v2.1.1/mapbox-gl.css' rel='stylesheet' />"
                script(crossorigin: "anonymous",
                       integrity: "sha384-KsvD1yqQ1/1+IA7gi3P0tyJcT3vR+NdBTt13hSJ2lnve8agRGXTTyNaBYmCR/Nwi",
                       src: "https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js")
                script(src: "https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js")
                "<link rel=\"stylesheet\" href=\"https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css\">"
                script(crossorigin: "anonymous",
                       integrity: "sha384-nsg8ua9HAw1y0W1btsyWgBklPnCUAFLuTMS2G72MMONqmOymq585AcH49TLBQObG",
                       src: "https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/js/bootstrap.min.js")

                script(src: "https://api.mapbox.com/mapbox.js/plugins/turf/v2.0.2/turf.min.js")
                script {
                """
                function updateMap(regionUUID) {
                    console.log(regionUUID)
                    var url = 'http://localhost:3000/region/' + regionUUID + '/geojson'
                    $.getJSON(url, function (geojson) {
                        var bbox = turf.extent(geojson);
                        var center = turf.center(geojson);
                    <!--        map.on('load', function () {-->

                            map.addSource(regionUUID, {
                                'type': 'geojson',
                                'data': geojson
                            });
                            map.addLayer({
                                'id': regionUUID + 'regionSourceLayer',
                                'type': 'fill',
                                'source': regionUUID,
                                'layout': {},
                                'paint': {
                                    'fill-color': '#088',
                                    'fill-opacity': 0.8
                                }
                            });
                            
                            map.fitBounds(bbox, {padding:20});
                    <!--        });    -->


                    });
                }
                """
                }
                style {
                    """
                        body { margin: 0; padding: 0; }
                        #map { position: absolute; top: 0; bottom: 0; width: 100%; }
                    """
                }
 
                h1 {
                    "Wine Regions"
                }
            }
            body {
                div(class: "row") {
                    div(class: "col-md-3") {
                        div(class: "accordian", id: "regionTable") {
                            regions.map { region in
                                createRegionCard(region: region, parentID: "regionTable")
                            }
                        }
                    }
                    div(class: "col-md-9") {
                        div(id: "map")
                    }
                }
                script {
                    """
                    mapboxgl.accessToken = 'pk.eyJ1Ijoicm9kZXJpYyIsImEiOiJja2t2ajNtMXMxZjdjMm9wNmYyZHR1ZWN3In0.mM6CghYW2Uil53LD5uQrGw';

                    var map = new mapboxgl.Map({
                        container: 'map',
                        style: 'mapbox://styles/mapbox/light-v10',
                        center: [-68.13734351262877, 45.137451890638886],
                        zoom: 12
                    });

                    """
                }
            }
        }
    }
}
