//
//  Fetcher.swift
//  ImageFeed
//
//  Created by Vladimir on 26.03.2025.
//

import Foundation


// MARK: - FetcherError
enum FetcherError: Error {
    case wrongThread, duplicateRequest, invalidRequest
}

// MARK: - Fetcher
/**
 Helper Class
 
 All service classes that fetch some data must satisfy same conditions.
 These conditions prevent race condition.
 The conditions are checked in `checkConditionsAndReturnRequest(newValue:latestValue:task:request:completion:)`.
 */
class Fetcher<T: Comparable, U> {
    
    func checkConditionsAndReturnRequest(newValue: T, latestValue: T?, task: URLSessionTask?, request: URLRequest?, completion: @escaping (Result<U, Error>) -> Void) -> URLRequest? {
        guard Thread.isMainThread else {
            assertionFailure("\(Self.self).checkConditionsAndReturnRequest: Trying to fetch profile from secondary thread")
            completion(.failure(FetcherError.wrongThread))
            return request
        }
        guard newValue != latestValue else {
            print("\(Self.self).checkConditionsAndReturnRequest: Duplicating request")
            completion(.failure(FetcherError.duplicateRequest))
            return request
        }
        guard let request else {
            assertionFailure("\(Self.self).checkConditionsAndReturnRequest: Failed to create request for fetching profile")
            completion(.failure(FetcherError.invalidRequest))
            return request
        }
        return request
    }
    
}
