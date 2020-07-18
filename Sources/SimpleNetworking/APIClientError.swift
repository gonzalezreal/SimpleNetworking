//
// APIClientError.swift
//
// Copyright (c) 2020 Guille Gonzalez
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the  Software), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED  AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

/// An error that occurs during an `APIClient` request.
public enum APIClientError<Error>: Swift.Error {
    case loadingError(Swift.Error)
    case decodingError(DecodingError)
    case apiError(APIError<Error>)

    internal init(_ error: Swift.Error) {
        switch error {
        case let apiError as APIError<Error>:
            self = .apiError(apiError)
        case let decodingError as DecodingError:
            self = .decodingError(decodingError)
        default:
            self = .loadingError(error)
        }
    }
}

public extension APIClientError {
    var loadingError: Swift.Error? {
        guard case let .loadingError(value) = self else { return nil }
        return value
    }

    var decodingError: DecodingError? {
        guard case let .decodingError(value) = self else { return nil }
        return value
    }

    var apiError: APIError<Error>? {
        guard case let .apiError(value) = self else { return nil }
        return value
    }
}
