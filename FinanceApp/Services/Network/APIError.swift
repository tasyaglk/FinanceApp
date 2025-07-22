//
//  APIError.swift
//  FinanceApp
//
//  Created by Тася Галкина on 17.07.2025.
//

import Foundation

struct APIError: Decodable, LocalizedError {
    let code: String
    let message: String
    
    var errorDescription: String? {
        message
    }
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed(statusCode: Int, error: APIError?)
    case decodingFailed(Error)
    case encodingFailed(Error)
    case noData
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL запроса"
        case .requestFailed(let statusCode, let error):
            switch statusCode {
            case 400:
                return error?.message ?? "Некорректные данные или неверный формат ID"
            case 401:
                return error?.message ?? "Неавторизованный доступ"
            case 404:
                return error?.message ?? "Ресурс не найден"
            case 409:
                return error?.message ?? "Конфликт - у счета есть транзакции"
            case 500:
                return error?.message ?? "Внутренняя ошибка сервера"
            default:
                return error?.message ?? "Ошибка запроса: \(statusCode)"
            }
        case .decodingFailed:
            return "Ошибка декодирования ответа"
        case .encodingFailed:
            return "Ошибка сериализации запроса"
        case .noData:
            return "Данные не получены"
        case .unauthorized:
            return "Ошибка авторизации. Проверьте токен."
        }
    }
}
