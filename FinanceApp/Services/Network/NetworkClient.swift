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
    func request<T: Decodable, U: Encodable>(endpoint: String, method: HTTPMethod, body: U?) async throws -> T
    func requestWithoutResponse<U: Encodable>(endpoint: String, method: HTTPMethod, body: U?) async throws
}

final class NetworkClient: NetworkClientProtocol {
    private let baseURL = "https://shmr-finance.ru/api/v1"
    private let token = "cnwkQ0lSkiFd5yazh9kSoLuO"
    
    func request<T: Decodable, U: Encodable>(endpoint: String, method: HTTPMethod, body: U?) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                request.httpBody = try encoder.encode(body)
            } catch {
                throw NetworkError.encodingFailed(error)
            }
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    
                    let formats = [
                        "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
                        "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
                        "yyyy-MM-dd'T'HH:mm:ssZ"
                    ]
                    
                    for format in formats {
                        let formatter = DateFormatter()
                        formatter.dateFormat = format
                        formatter.locale = Locale(identifier: "en_US_POSIX")
                        formatter.timeZone = TimeZone(secondsFromGMT: 0)
                        if let date = formatter.date(from: dateString) {
                            return date
                        }
                    }
                    
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateString)")
                }
                
                return try decoder.decode(T.self, from: data)
            } catch {
                
                throw NetworkError.decodingFailed(error)
            }
            
        case 400, 401, 404, 409, 500:
            let error = try? JSONDecoder().decode(APIError.self, from: data)
            throw NetworkError.requestFailed(statusCode: httpResponse.statusCode, error: error)
        default:
            throw NetworkError.requestFailed(statusCode: httpResponse.statusCode, error: nil)
        }
    }
    
    func requestWithoutResponse<U: Encodable>(endpoint: String, method: HTTPMethod, body: U?) async throws {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                request.httpBody = try encoder.encode(body)
            } catch {
                throw NetworkError.encodingFailed(error)
            }
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 400, 401, 404, 409, 500:
            let error = try? JSONDecoder().decode(APIError.self, from: data)
            throw NetworkError.requestFailed(statusCode: httpResponse.statusCode, error: error)
        default:
            throw NetworkError.requestFailed(statusCode: httpResponse.statusCode, error: nil)
        }
    }
}
