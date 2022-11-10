//
//  ViewController.swift
//  MarvelApp
//
//  Created by Aleksandr Rybachev on 05.11.2022.
//

import UIKit

class ViewController: UIViewController {
    
    let provider = ServiceProvider<MarvelService>()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        NetworkManager.shared.fetchData(from: Constants.publicKey ?? "") { marvelModel in
            print("test")
        }
        
        provider.load(service: .character(identifier: "spider-man")) { result in
            switch result {
            case .success(let resp):
                print(resp)
            case .failure(let error):
                print(error.localizedDescription)
            case .empty:
                print("No data")
            }
        }
    }


}

