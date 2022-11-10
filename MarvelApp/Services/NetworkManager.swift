//
//  NetworkManager.swift
//  MarvelApp
//
//  Created by Aleksandr Rybachev on 05.11.2022.
//

import Foundation

/*
typealias ResultCallback<Value> = (Result<Value, Error>) -> Void

protocol APIClient {
    func send<T: APIRequest>(_ request: T, completion: @escaping ResultCallback<T.Response>)
}

protocol APIRequest: Encodable {
    
    associatedtype Response: Decodable
    var resourceName: String { get }
}

protocol APIResponse: Decodable {
    
}

struct GetCharacters: APIRequest {
    typealias Response = [ComicCharacter]
    
    var resourceName: String {
        return "characters"
    }
    
    // PARAMETERS
    let name: String?
    let nameStartsWith: String?
    let limit: Int?
    let offset: Int?
    
    init(name: String? = nil, nameStartsWith: String? = nil, limit: Int? = nil, offset: Int? = nil) {
        self.name = name
        self.nameStartsWith = nameStartsWith
        self.limit = limit
        self.offset = offset
    }
}

struct ComicCharacter: Decodable {
    let id: Int
    let name: String?
    let description: String?
    let thumbnail: Image?
}

struct Image: Decodable {
    enum ImageKeys: String, CodingKey {
        case path = "path"
        case fileExtension = "extension"
    }
    
    let url: URL
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ImageKeys.self)
        
        let path = try container.decode(String.self, forKey: ImageKeys.path)
        let fileExtension = try container.decode(String.self, forKey: ImageKeys.fileExtension)
        
        guard let url = URL(string: "\(path).\(fileExtension)") else { throw MarvelError.decoding}
        
        self.url = url
    }
}

struct MarvelResponse<Response: Decodable>: Decodable {
    let status: String?
    let message: String?
    let data: DataContainer<Response>?
}

struct DataContainer<Results: Decodable>: Decodable {
    let offset: Int
    let limit: Int
    let total: Int
    let count: Int
    let results: Results
}

struct NetworkRequest: APIClient {
    
    func send<T: APIRequest>(_ request: T, completion: @escaping ResultCallback<DataContainer<T.Response>>) {
        let endpoint = self.endpoint(for: request)
        
        let task  = session.dataTask(with: URLRequest(url: endpoint)) { data, response, error in
            if let data = data {
                do {
                    let marvelResponse = try JSONDecoder().decode(MarvelResponse<T.Response>.self, from: data)
                    
                    if let dataContainer = marvelResponse.data {
                        completion(.success(dataContainer))
                    } else if let message = marvelResponse.message {
                        completion(.failure(MarvelError.server(message: message)))
                    } else {
                        completion(.failure(MarvelError.decoding))
                    }
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
*/

// MARK: - OLD

struct NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchData(from url: String?, with completion: @escaping(Comic) -> Void) {
        
//        let param = ["code": 200, "status": "Ok", "etag": "f0fbae65eb2f8f28bdeea0a29be8749a4e67acb3"] as [String : Any]
              
        guard let url = URL(string: url ?? "") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        print("test1")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("test2")
                print(data ?? "empty data")
                print(error?.localizedDescription ?? "No error description")
                return
            }
            
            do {
                print("test3")
                let comics = try JSONDecoder().decode(Comic.self, from: data)
                DispatchQueue.main.async {
                    completion(comics)
                }
            } catch {
                print("test4")
                print(error)
            }
        }.resume()
    }
}
            
        
