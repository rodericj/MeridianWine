//
//  File.swift
//  
//
//  Created by Roderic Campbell on 1/27/21.
//

import Foundation

final class Database {
    struct MigrationRegion: Encodable {
        let osmID: Int
        let title: String
        let children: [MigrationRegion]
    }
    let regionTree = [
        MigrationRegion(osmID: 1403916,  title: "France", children: [
            MigrationRegion(osmID: 7405, title: "Gironde", children: [
                MigrationRegion(osmID: 963201, title: "Saint-Estèphe", children: []),
                MigrationRegion(osmID: 89248, title: "Saint-Émilion", children: []),
                MigrationRegion(osmID: 92963, title: "Barsac", children: []),
                MigrationRegion(osmID: 58582, title: "Margaux", children: [])
            ]),
            MigrationRegion(osmID: 3792878, title: "Bourgogne", children: [
                MigrationRegion(osmID: 7424, title: "Côte-d'Or", children: [
                    MigrationRegion(osmID: 1684815, title: "Beaune", children: [
                        MigrationRegion(osmID: 127321, title: "Volnay", children: []),
                    ]),
                ]),

            ])
        ]),
        MigrationRegion(osmID: 1311341, title: "Spain", children: [
            MigrationRegion(osmID: 6426654, title: "Rioja", children: [])
        ]),
        MigrationRegion(osmID: 365331, title: "Italy", children: [
            MigrationRegion(osmID: 40095, title: "Apulia", children: []),
            MigrationRegion(osmID: 41977, title: "Tuscany", children: []),
            MigrationRegion(osmID: 42004, title: "Umbria", children: [])
        ])
    ]
}
