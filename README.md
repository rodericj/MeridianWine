# MeridianWine

MeridianWine provides access to all (pending) of the wine regions around the world through a simple REST api. It leverages the [Meridian](https://github.com/khanlou/Meridian) server side swift framework.

This is the second iteration of 
## Routes

### GET /region

This will return a nested tree structure containing all of the wine regions in the database. At the top level are country regions. Below that are sub regions, below those are more subregions. It's subregions all the way down.

``` javascript

{
    "id": "20013FA8-CD71-4F30-82C5-C3C512B9C914",
    "title": "France métropolitaine",
    "osmID": 1403916,
    "children": [
      {
        "id": "86FEE3DA-6346-4EA0-BED8-F2640DD0C519",
        "title": "Gironde",
        "osmID": 7405,
        "children": [
          {
            "id": "1FFC5161-3CE8-4AB3-A084-CF69987794D4",
            "title": "Saint-Estèphe",
            "osmID": 963201,
            "children": []
          },
          {
            "id": "0B29B20E-DEBF-41B1-8614-2530D64C0E03",
            "title": "Saint-Émilion",
            "osmID": 89248,
            "children": []
          },
          {
            "id": "F3BA140C-A199-49D7-B351-3BA8C02FE61B",
            "title": "Barsac",
            "osmID": 92963,
            "children": []
          },
          {
            "id": "49AAFFA5-1CCC-45FD-91C9-091E398CD633",
            "title": "Margaux",
            "osmID": 58582,
            "children": []
          }
        ]
      },
      ...
```

### POST /Region?osmid=12345

Creating a region takes an osmid which maps (ha!) to an OpenStreenMap relation, for example: [Volnay](https://www.openstreetmap.org/relation/127321). Volnay's detailed information can be found through an API provided by OpenStreetMap's [Nominatim](https://nominatim.openstreetmap.org/details.php?osmtype=R&osmid=127321&class=boundary&addressdetails=1&hierarchy=0&group_hierarchy=1&polygon_geojson=1&format=json).

POSTing an osmid will create a reference in database for the appropriate region.

### PATCH /Region?parent_id=XYZ-ABC-123

PATCHing a region will update it's parent. This establishes the tree structure.


## Setup
MeridianWine is deployed to Heroku. It uses Postgresql for it's data store. 

## Clients


## Errors encountered
### No process running
`2021-02-01T05:45:55.191188+00:00 heroku[router]: at=error code=H14 desc="No web processes running" method=GET path="/region" host=tranquil-garden-84812.herokuapp.com request_id=40190aa2-4add-4bd5-99da-76ced51e9abf fwd="108.225.76.255" dyno= connect= service= status=503 bytes= protocol=http`

Stackoverlow'd to [here](https://stackoverflow.com/questions/41804507/h14-error-in-heroku-no-web-processes-running) where it was suggested that we scale up with `heroku ps:scale web=1` but that didn't work.
