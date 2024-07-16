//
//  DictionaryResponse.swift
//  FindMyAcronym
//
//  Created by Pedro on 15-07-24.
//

import Foundation

struct DictionaryResponse: Codable {
    let lfs: [LongFormApi]
}

struct LongFormApi: Codable {
    let lf: String
    let freq, since: Int
}
