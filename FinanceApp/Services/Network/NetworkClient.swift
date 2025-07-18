//
//  NetworkClient.swift
//  FinanceApp
//
//  Created by Тася Галкина on 17.07.2025.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol NetworkClientProtocol {
    func request<T: Decodable,
                U: Encodable>(endpoint: String, method: HTTPMethod, body: U?) async throws -> T
}
