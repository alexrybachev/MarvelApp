//
//  APIClient.swift
//  MarvelApp
//
//  Created by Aleksandr Rybachev on 10.11.2022.
//

import Foundation

struct Product: Codable {
    var id: Int?
    var title: String?
    var description: String?
    var price: Int?
    var rating: Float?
    var brand: String?
    var category: String
}

// MARK: - PROTOCOL

protocol Managable {
    
    func request<T: Codable>(
        url: URL,
        httpMethod: ServiceMethod,
        body: Data?,
        headers: [String: String]?,
        expectingReturnType: T.Type
    ) async throws -> T
}

// MARK: - ENUMs
enum ErrorMessages: String {
    case somethingWentWrong = "Something went wrong!"
}

enum ServiceMethod: String {
    case get = "GET"
    case post = "POST"
}

enum APIManagerError: Error {
    case conversionFailedToHTTPURLResponse
    case serilizationFailed
    case urlError(statuscode: Int)
    case somethingWentWrong
    case badURL
}

enum HeaderKeyValue: String {
    case formUrlEncoded = "application/x-www-form-urlencoded"
    case contentType = "Content-Type"
    case accept = "Accept"
    case applicationJson = "application/json"
}

// MARK: - CLASS

final class APIManager {
    
    public internal(set) var session: URLSession = .shared
    
    static let shared: Managable = APIManager()
    
    private init() {}
}

extension APIManager: Managable {
    
    func request<T: Codable>(
        url: URL,
        httpMethod: ServiceMethod,
        body: Data?,
        headers: [String : String]? = nil,
        expectingReturnType: T.Type = T.self
    ) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        if let body = body, httpMethod != .get {
            request.httpBody = body
        }
        request.addHeaders(from: headers)
        return try await self.responseHandler(
            session.data(for: request)
        )
    }
    
    func responseHandler<T: Codable>(_ dataWithResponse: (data: Data, response: URLResponse)) async throws -> T {
        guard let response = dataWithResponse.response as? HTTPURLResponse else {
            throw APIManagerError.conversionFailedToHTTPURLResponse
        }
        try response.statusCodeChecker()
        return try JSONDecoder().decode(T.self, from: dataWithResponse.data)
    }
    
}

class AppService<T: Codable> {
    
    var headers: [String: String]?
    var parameters: [String: String]?
    
    func call(with urlString: String, serviceMethod: ServiceMethod) async throws -> T {
        guard let url = URL(string: urlString) else { throw APIManagerError.badURL }
        let body = try (parameters ?? [:]).serialize()
                        return try await APIManager.shared.request(
                            url: url,
                            httpMethod: serviceMethod,
                            body: body,
                            headers: self.headers,
                            expectingReturnType: T.self
                        )
    }
}

// MARK: - ENTENSIONs

extension URLRequest {
    
    mutating func addHeaders(from headers: [String: String]? = nil) {
        guard let headers = headers, !headers.isEmpty else {
            self.defaultHeaders()
            return
        }
        
        for header in headers {
            self.addValue(header.value, forHTTPHeaderField: header.key)
        }
    }
    
    mutating func defaultHeaders() {
        self.addValue(HeaderKeyValue.formUrlEncoded.rawValue,
                      forHTTPHeaderField: HeaderKeyValue.contentType.rawValue)
        
        self.addValue(HeaderKeyValue.applicationJson.rawValue,
                      forHTTPHeaderField: HeaderKeyValue.accept.rawValue)
    }
}

extension HTTPURLResponse {
    func statusCodeChecker() throws {
        switch self.statusCode {
        case 200...299:
            return
        default:
            throw APIManagerError.urlError(statuscode: self.statusCode)
        }
    }
}

extension Error {
    
    var description: String {
        ((self as? APIManagerError)?.errorDescription) ?? self.localizedDescription
    }
}

extension APIManagerError {
    
    var showableError: Self {
        switch self {
        case .urlError(_):
            return self
        default:
            return .somethingWentWrong
        }
    }
    
    /// Makes things easier
    var showableDescription: String {
        developerMode ? self.showableError.errorDescription : self.errorDescription
    }
    
    /// Default Error Description
    var errorDescription: String {
        switch self {
        case .conversionFailedToHTTPURLResponse:
            return "Typecasting failed."
        case .urlError(let code):
            return ErrorMessages.somethingWentWrong.rawValue + "underlying status code: \(code)"
        case .somethingWentWrong:
            return ErrorMessages.somethingWentWrong.rawValue
        case .serilizationFailed:
            return "JSONSerilization Failed"
        case .badURL:
            return "Malformed URL was sent to session"
        }
    }
}

public extension Dictionary {
    
    func serialize() throws -> Data {
        try JSONSerialization.data(
            withJSONObject: self,
            options: .prettyPrinted
        )
    }
}
