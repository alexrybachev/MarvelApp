//
//  NetworkManagerNew.swift
//  MarvelApp
//
//  Created by Aleksandr Rybachev on 08.11.2022.
//

import Foundation
import UIKit

enum NetworkError: Error {
    case timeeOut
    case connectionFailure
    case noData
    case invalidURL
}

class NetworkManagerNew {
    
    static let shared = NetworkManagerNew()
    private let session: URLSession
    
    private let timeout: Double = 5
    private let retryAfterSeconds: Double = 3.0
    private let maxRetries: Int = 5
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func call(with request: URLRequest, attempt: Int = 0, completion: @escaping (Result<Data, Error>) -> Void) {
        
        var inProgress: Bool = true
        
        let task = session.dataTask(with: request) { data, response, error in
            inProgress = false
            
            if error == nil {
                if let data = data {
                    completion(.success(data))
                } else {
                    completion(.failure(NetworkError.noData))
                }
            } else {
                
                // check if should retry again
                if attempt < self.maxRetries {
                    
                    // retry after timeout
                    self.setTimeout(self.retryAfterSeconds) {
                        self.call(with: request, attempt: attempt + 1, completion: completion)
                    }
                } else {
                    // pass back failure
                    completion(.failure(NetworkError.connectionFailure))
                }
            }
        }
        
        task.resume()
        
        // cancel request of taking to long
        setTimeout(timeout) {
            if inProgress {
                task.cancel()
                
                // attempt retry
                if attempt < self.maxRetries {
                    self.call(with: request, attempt: attempt + 1, completion: completion)
                } else {
                    
                    // pass back failure
                    completion(.failure(NetworkError.timeeOut))
                }
            }
        }
    }
    
    private func setTimeout(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}

struct Episode {
    
}

// MARK: - EXAMPLE

let urlString: String = "some_link"

class ExampleService {
    private let networkManager: NetworkManagerNew = .shared
    
    func getData(completion: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: URL(string: urlString)!)
        networkManager.call(with: request) { result in
            completion(result)
        }
        
    }
}

class ExampleViewController: UIViewController {
    private let service: ExampleService = ExampleService()
    
    private func getData() {
        service.getData { result in
            switch result {
            case .success(_):
                print("success")
            case .failure(_):
                print("failure")
            }
        }
    }
}

