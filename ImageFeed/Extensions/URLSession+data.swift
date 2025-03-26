//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Vladimir on 05.03.2025.
//

import Foundation


enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}


extension URLSession {
    
    func data(for request: URLRequest, completion: @escaping (Result<Data,Error>) -> Void) -> URLSessionTask {
        let mainThreadCompletionHandler: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = dataTask(with: request) { data, response, error in
            if let data, let response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200..<300 ~= statusCode {
                    mainThreadCompletionHandler(.success(data))
                } else {
                    print(NetworkError.httpStatusCode(statusCode))
                    mainThreadCompletionHandler(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error {
                print(NetworkError.urlRequestError(error))
                mainThreadCompletionHandler(.failure(NetworkError.urlRequestError(error)))
            } else {
                print(NetworkError.urlSessionError)
                mainThreadCompletionHandler(.failure(NetworkError.urlSessionError))
            }
        }
        return task
    }
    
}

extension URLSession {
    
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        let task = data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let object = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(object))
                } catch {
                    print(error)
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
    
}
