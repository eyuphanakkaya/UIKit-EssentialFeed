//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Eyüphan Akkaya on 22.08.2026.
//

import Foundation

public typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>


public protocol HTTPClient {
    func get(url: URL, completion: @escaping (HTTPClientResult)-> Void )
}
