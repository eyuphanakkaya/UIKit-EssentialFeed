//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Eyüphan Akkaya on 22.08.2026.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}


public protocol HTTPClient {
    func get(url: URL, completion: @escaping (HTTPClientResult)-> Void )
}
