//
//  MarvelService.swift
//  MarvelApp
//
//  Created by Aleksandr Rybachev on 06.11.2022.
//

import Foundation

enum MarvelService {
    case characters(name: String)
    case character(identifier: String)
}

extension MarvelService: Service {
    var baseURL: String {
        return "https://gateway.marvel.com:443"
    }
    
    var path: String {
        switch self {
        case .characters(_):
            return "/v1/public/characters"
        case .character(identifier: let identifier):
            return "/v1/public/characters/\(identifier)"
        }
    }
    
    var parameters: [String : Any]? {
        // defualt params
        var params: [String: Any] = ["apikey": "MY_API_KEY"]
        
        switch self {
        case .characters(name: let name):
            params["name"] = name
        case .character(_):
            break
        }
        
        return params
    }
    
    var method: ServiceMethod {
        return .get
    }
    
}
