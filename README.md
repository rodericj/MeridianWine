# MeridianWine

MeridianWine provides access to all (pending) of the wine regions around the world through a simple REST api. 

## Routes

### GET /region

This will return a nested tree structure containing all of the wine regions in the database. At the top level are country regions. Below that are sub regions, below those are more subregions. It's subregions all the way down.

```javascript

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

