import Foundation
import HTML
import Meridian

public struct GetRegionHTML: Responder {
    @EnvironmentObject var database: Database

    public init() {}
    
    private var headerContent: Node {
        return header {
            meta(charset: "utf-8", content: "text/html", httpEquiv: "Content-Type")
            script(src: "https://code.jquery.com/jquery-3.5.1.min.js")
            script(src: "https://api.mapbox.com/mapbox.js/plugins/turf/v2.0.2/turf.min.js")
            script(src: "https://api.mapbox.com/mapbox-gl-js/v2.1.1/mapbox-gl.js")
            "<link href='https://api.mapbox.com/mapbox-gl-js/v2.1.1/mapbox-gl.css' rel='stylesheet' />"
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
                var url = '/region/' + regionUUID + '/geojson'
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

            $(document).ready(function () {

                $('#sidebarCollapse').on('click', function () {
                    $('#sidebar').toggleClass('active');
                });

            });
            """
            }
            style {
                """
                    body { margin: 0; padding: 0; }
                    #map { position: absolute; top: 0; bottom: 0; width: 100%; }
                """
            }

            style {
                """
                .wrapper {
                    display: flex;
                    width: 100%;
                    align-items: stretch;
                }

                .wrapper {
                    display: flex;
                    align-items: stretch;
                }

                #sidebar {
                    min-width: 250px;
                    max-width: 250px;
                }

                #sidebar.active {
                    margin-left: -250px;
                }

                #sidebar {
                    min-width: 250px;
                    max-width: 250px;
                    min-height: 100vh;
                }

                a[data-toggle="collapse"] {
                    position: relative;
                }

                .dropdown-toggle::after {
                    display: block;
                    position: absolute;
                    top: 50%;
                    right: 20px;
                    transform: translateY(-50%);
                }

                @media (max-width: 768px) {
                    #sidebar {
                        margin-left: -250px;
                    }
                    #sidebar.active {
                        margin-left: 0;
                    }
                }

                @import "https://fonts.googleapis.com/css?family=Poppins:300,400,500,600,700";


                body {
                    font-family: 'Poppins', sans-serif;
                    background: #fafafa;
                }

                p {
                    font-family: 'Poppins', sans-serif;
                    font-size: 1.1em;
                    font-weight: 300;
                    line-height: 1.7em;
                    color: #999;
                }

                a, a:hover, a:focus {
                    color: inherit;
                    text-decoration: none;
                    transition: all 0.3s;
                }

                #sidebar {
                    /* don't forget to add all the previously mentioned styles here too */
                    background: #7386D5;
                    color: #fff;
                    transition: all 0.3s;
                }

                #sidebar .sidebar-header {
                    padding: 20px;
                    background: #6d7fcc;
                }

                #sidebar ul.components {
                    padding: 20px 0;
                    border-bottom: 1px solid #47748b;
                }

                #sidebar ul p {
                    color: #fff;
                    padding: 10px;
                }

                #sidebar ul li a {
                    padding: 10px;
                    font-size: 1.1em;
                    display: block;
                }
                #sidebar ul li a:hover {
                    color: #7386D5;
                    background: #fff;
                }

                #sidebar ul li.active > a, a[aria-expanded="true"] {
                    color: #fff;
                    background: #6d7fcc;
                }
                ul ul a {
                    font-size: 0.9em !important;
                    padding-left: 30px !important;
                    background: #6d7fcc;
                }

                """
            }
        }

    }
    
    private func printRegionInSidebar(_ region: Region) -> Node {
        // leaf node
        if region.children.isEmpty {
            return li {
                a(href:"#",
                  customAttributes: ["onclick": "updateMap('\(region.id)')"]) {
                    region.title
                }
            }
        } else {
            print("\(region.title) has \(region.children.count) children")
            return li {
                a(href: "#\(region.title)Submenu",
                  customAttributes: ["data-toggle": "collapse",
                                     "aria-expanded": "false",
                                     "class": "dropdown-toggle",
                                     "onclick": "updateMap('\(region.id)')"
                  ]) {
                    region.title
                }
                ul(class: "collapse list-unstyled", id: "\(region.title)Submenu") {
                    region.children.map { printRegionInSidebar($0) }
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
            headerContent
            body {
                // From here: https://bootstrapious.com/p/bootstrap-sidebar
                div(class: "wrapper") {
                    nav(id: "sidebar") {
                        div(class: "sidebar-header") {
                            h3 { "Wine Region" }
                            ul(class: "list-unstyled components") {
                                regions.map { printRegionInSidebar($0) }
                            }
                        }
                    }
                    div(id: "content") {
                        div(id: "map")
                        nav(class: "navbar navbar-expand-lg navbar-light bg-light") {
                            div(class: "container-fluid") {
                                button(class: "btn btn-info", id: "sidebarCollapse", type: "button") {
                                    i(class: "fas fa-align-left")
                                    span { "Toggle Sidebar" }
                                }
                            }
                        }
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
