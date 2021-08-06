import Foundation

public enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
}

public enum RPCError: Error {
    case httpError
    case httpErrorCode(Int)
    case invalidResponseNoData
    case invalidResponse(ResponseError)
    case unknownResponse
    case retry
}

public class NetworkingRouter {

    let endpoint: RPCEndpoint
    private let urlSession: URLSession
    public init(endpoint: RPCEndpoint, session: URLSession = .shared) {
        self.endpoint = endpoint
        self.urlSession = session
    }

    public func request<T: Decodable>(
        method: HTTPMethod = .post,
        bcMethod: String = #function,
        parameters: [Encodable?] = [],
        onComplete: @escaping (Result<T, Error>) -> Void
    ) {
        let url = endpoint.url
        let params = parameters.compactMap {$0}

        let bcMethod = bcMethod.replacingOccurrences(of: "\\([\\w\\s:]*\\)", with: "", options: .regularExpression)
        let requestAPI = SolanaRequest(method: bcMethod, params: params)

        Logger.log(message: "\(method.rawValue) \(bcMethod) [id=\(requestAPI.id)] \(params.map(EncodableWrapper.init(wrapped:)).jsonString ?? "")", event: .request, apiMethod: bcMethod)

        ContResult<URLRequest, Error>.init { cb in
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method.rawValue
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                urlRequest.httpBody = try JSONEncoder().encode(requestAPI)
                cb(.success(urlRequest))
                return
            } catch let ecodingError {
                cb(.failure(ecodingError))
                return
            }

        }
        .flatMap { urlRequest in
            ContResult<(data: Data?, response: URLResponse?), Error>.init { cb in
                let task = self.urlSession.dataTask(with: urlRequest) { (data, response, error) in
                    if let error = error {
                        cb(.failure(error))
                        return
                    }
                    cb(.success((data: data, response: response)))
                    return
                }
                task.resume()
            }
            .onSuccess { (data: Data?, response: URLResponse?) in
                Logger.log(message: String(data: data ?? Data(), encoding: .utf8) ?? "", event: .response, apiMethod: bcMethod)
            }
        }
        .flatMap {
            if let httpURLResponse = $0.response as? HTTPURLResponse {
                return .success((data: $0.data, httpURLResponse: httpURLResponse))
            } else {
                return .failure(RPCError.httpError)
            }
        }
        .flatMap { (data: Data?, httpURLResponse: HTTPURLResponse) in
            if (200..<300).contains(httpURLResponse.statusCode) {
                return .success((data: data, httpURLResponse: httpURLResponse))
            } else if httpURLResponse.statusCode == 429 {
                // TODO: Retry
                return .failure(RPCError.retry)
            } else {
                return .failure(RPCError.httpErrorCode(httpURLResponse.statusCode))
            }
        }
        .flatMap { (data: Data?, httpURLResponse: HTTPURLResponse) in
            guard let responseData = data else {
                return .failure(RPCError.invalidResponseNoData)
            }
            return .success((responseData, httpURLResponse))
        }
        .flatMap { (responseData: Data, _: HTTPURLResponse) in
            do {
                let decoded = try JSONDecoder().decode(Response<T>.self, from: responseData)
                return .success(decoded)
            } catch let error {
                return .failure(error)
            }
        }
        .flatMap { (decoded: Response<T>) in
            if let result = decoded.result {
                return .success(result)
            } else if let responseError = decoded.error {
                return .failure(RPCError.invalidResponse(responseError))
            } else {
                return .failure(RPCError.unknownResponse)
            }
        }
        .run(onComplete)
    }
    
   public func batchRequest<T: Decodable>(
        method: HTTPMethod = .post,
        bcMethod: String = #function,
        batchParameters: [[Encodable?]?] = [],
        onComplete: @escaping (Result<[Response<T>], Error>) -> Void
    ) {
        let url = endpoint.url
        let params = batchParameters.compactMap {$0}

        let bcMethod = bcMethod.replacingOccurrences(of: "\\([\\w\\s:]*\\)", with: "", options: .regularExpression)
        var requestAPIarray: [SolanaRequest] = []
        for request in params {
          if let request = request as? [Encodable] {
            requestAPIarray.append(SolanaRequest(method: bcMethod, params: request))
          }
        }
        Logger.log(message: "\(method.rawValue) \(bcMethod) batch:\(requestAPIarray.count))", event: .request, apiMethod: bcMethod)

        ContResult<URLRequest, Error>.init { cb in
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method.rawValue
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                urlRequest.httpBody = try JSONEncoder().encode(requestAPIarray)
                cb(.success(urlRequest))
                return
            } catch let ecodingError {
                cb(.failure(ecodingError))
                return
            }

        }
        .flatMap { urlRequest in
            ContResult<(data: Data?, response: URLResponse?), Error>.init { cb in
                let task = self.urlSession.dataTask(with: urlRequest) { (data, response, error) in
                    if let error = error {
                        cb(.failure(error))
                        return
                    }
                    cb(.success((data: data, response: response)))
                    return
                }
                task.resume()
            }
            .onSuccess { (data: Data?, response: URLResponse?) in
                Logger.log(message: String(data: data ?? Data(), encoding: .utf8) ?? "", event: .response, apiMethod: bcMethod)
            }
        }
        .flatMap {
            if let httpURLResponse = $0.response as? HTTPURLResponse {
                return .success((data: $0.data, httpURLResponse: httpURLResponse))
            } else {
                return .failure(RPCError.httpError)
            }
        }
        .flatMap { (data: Data?, httpURLResponse: HTTPURLResponse) in
            if (200..<300).contains(httpURLResponse.statusCode) {
                return .success((data: data, httpURLResponse: httpURLResponse))
            } else if httpURLResponse.statusCode == 429 {
                // TODO: Retry
                return .failure(RPCError.retry)
            } else {
                return .failure(RPCError.httpErrorCode(httpURLResponse.statusCode))
            }
        }
        .flatMap { (data: Data?, httpURLResponse: HTTPURLResponse) in
            guard let responseData = data else {
                return .failure(RPCError.invalidResponseNoData)
            }
            return .success((responseData, httpURLResponse))
        }
        .flatMap { (responseData: Data, _: HTTPURLResponse) in
            do {
                let decoded = try JSONDecoder().decode([Response<T>].self, from: responseData)
                return .success(decoded)
            } catch {
               print(error)
                return .failure(error)
            }
        }
        .flatMap { (decoded: [Response<T>]) in
        		return .success(decoded)
        }
        .run(onComplete)
    }
}

public extension Data {
    var prettyJson: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding: .utf8) else {
                  return nil
              }
        return prettyPrintedString
    }

    func printJson() {
        if let JSONString = prettyJson {
            print(JSONString)
        }
    }
}
