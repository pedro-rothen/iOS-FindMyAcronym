//
//  DictionaryResponse.swift
//  FindMyAcronym
//
//  Created by Pedro on 15-07-24.
//

import Foundation

struct DictionaryResponse: Decodable {
    let lfs: [LongFormApi]
}

struct LongFormApi: Decodable {
    let lf: String
    let freq, since: Int
}
