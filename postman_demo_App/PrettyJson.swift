//
//  PrettyJson.swift
//  postman_demo_App
//
//  Created by Roro Solutions on 12/10/22.
//

import Foundation
import SwiftUI
struct PrettyJson: Codable{
    struct tokens: Codable{
        let accessToken: String
        let refreshToken: String
        let expires: Int64
    }
    let jsonWebToken: tokens
    let loginStatus: Int
}



