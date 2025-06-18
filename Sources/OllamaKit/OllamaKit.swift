// The Swift Programming Language
// https://docs.swift.org/swift-book

import Combine
import Foundation

public class OllamaInstance {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let baseURL: URL
    let configuration: URLSessionConfiguration

    public init(_ baseURL: URL, session configuration: URLSessionConfiguration) {
        self.baseURL = baseURL
        self.configuration = configuration
    }

    public func getOllamaVersion() async throws -> String {
        let response = try await jsonRequest(
            item: [String: String].self, method: "GET", path: "/api/version")

        guard let version = response["version"] else {
            throw OllamaError.invalidVersion
        }

        return version
    }

    func jsonRequest<T: Decodable>(
        item: T.Type,
        method: String,
        path: String,
        data: Codable? = nil
    ) async throws -> T {
        let data: Data = try await self.request(method: method, path: path, data: data)
        return try self.decoder.decode(T.self, from: data)
    }

    func jsonStreamRequest<T: Decodable>(
        item: T.Type,
        method: String,
        path: String,
        data: Codable? = nil
    ) throws -> AsyncThrowingStream<T, Error> {
        let decoder = self.decoder
        let dataStream = try stream(method: method, path: path, data: data)

        return AsyncThrowingStream<T, Error> { @Sendable continuation in
            Task { @MainActor in
                do {
                    for try await lineData in dataStream {
                        let decodedItem = try decoder.decode(T.self, from: lineData)
                        continuation.yield(decodedItem)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private func stream(
        method: String,
        path: String,
        data: Codable? = nil
    ) throws -> AsyncThrowingStream<Data, Error> {
        let configuration = self.configuration

        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method

        if let data = data {
            let encodedData = try self.encoder.encode(data)
            request.httpBody = encodedData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return AsyncThrowingStream { @Sendable continuation in
            Task { @MainActor in
                let delegate = AsyncStreamDelegate(continuation: continuation)

                let session = URLSession(
                    configuration: configuration,
                    delegate: delegate,
                    delegateQueue: nil)

                let task = session.dataTask(with: request)
                task.resume()
            }
        }
    }

    private func request(method: String, path: String, data: Codable? = nil) async throws -> Data {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method

        if let data = data {
            let encodedData = try self.encoder.encode(data)
            request.httpBody = encodedData
        }

        let session = URLSession(configuration: configuration)
        let (data, response) = try await session.data(for: request)

        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw OllamaError.invalidResponse
        }

        return data
    }
    
    func request(method: String, path: String, data: Codable? = nil) async throws -> Int {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method

        if let data = data {
            let encodedData = try self.encoder.encode(data)
            request.httpBody = encodedData
        }

        let session = URLSession(configuration: configuration)
        let (data, response) = try await session.data(for: request)

        guard let response = response as? HTTPURLResponse else {
            throw OllamaError.invalidResponse
        }
        
        return response.statusCode
    }
}

enum OllamaError: Error {
    case invalidResponse
    case invalidStatusCode
    case invalidVersion
    case modelNotFound
}

// MARK: - Generate Methods

extension OllamaInstance {
    public func generateCompletion(
        model: String,
        prompt: String,
        suffix: String? = nil,
        images: [Data]? = nil,
        think: Bool? = nil,
        format: Data? = nil,
        options: ModelOptions? = nil,
        system: String? = nil,
        template: String? = nil,
        raw: Bool? = nil,
        keepAlive: String? = nil
    ) throws -> AsyncThrowingStream<GenerateCompletionResponse, Error> {
        let request = GenerateCompletionRequest(
            stream: true,
            model: model,
            prompt: prompt,
            suffix: suffix,
            images: images,
            think: think,
            format: format,
            options: options,
            system: system,
            template: template,
            raw: raw,
            keepAlive: keepAlive)
        
        return try jsonStreamRequest(
            item: GenerateCompletionResponse.self,
            method: "POST",
            path: "/api/generate",
            data: request)
    }
    
    public func generateCompletion(
        model: String,
        prompt: String,
        suffix: String? = nil,
        images: [Data]? = nil,
        think: Bool? = nil,
        format: Data? = nil,
        options: ModelOptions? = nil,
        system: String? = nil,
        template: String? = nil,
        raw: Bool? = nil,
        keepAlive: String? = nil
    ) async throws -> GenerateCompletionResponse {
        let request = GenerateCompletionRequest(
            stream: false,
            model: model,
            prompt: prompt,
            suffix: suffix,
            images: images,
            think: think,
            format: format,
            options: options,
            system: system,
            template: template,
            raw: raw,
            keepAlive: keepAlive)
        
        return try await jsonRequest(
            item: GenerateCompletionResponse.self,
            method: "POST",
            path: "/api/generate",
            data: request)
    }
    
    public func generateChatCompletion(
        model: String,
        think: Bool? = nil,
        messages: [Message],
        tools: [ToolItem]? = nil,
        format: Data? = nil,
        options: ModelOptions? = nil,
        keepAlive: String? = nil
    ) throws -> AsyncThrowingStream<GenerateChatCompletionResponse, Error> {
        let request = GenerateChatCompletionRequest(
            stream: true,
            model: model,
            think: think,
            messages: messages,
            tools: tools,
            format: format,
            options: options,
            keepAlive: keepAlive)
        
        return try jsonStreamRequest(
            item: GenerateChatCompletionResponse.self,
            method: "POST",
            path: "/api/chat",
            data: request)
    }
    
    public func generateChatCompletion(
        model: String,
        think: Bool? = nil,
        messages: [Message],
        tools: [ToolItem]? = nil,
        format: Data? = nil,
        options: ModelOptions? = nil,
        keepAlive: String? = nil
    ) async throws -> GenerateChatCompletionResponse {
        let request = GenerateChatCompletionRequest(
            stream: false,
            model: model,
            think: think,
            messages: messages,
            tools: tools,
            format: format,
            options: options,
            keepAlive: keepAlive)
        
        return try await jsonRequest(
            item: GenerateChatCompletionResponse.self,
            method: "POST",
            path: "/api/chat",
            data: request)
            
    }
    
    public func generateEmbeddings(
        model: String,
        input: String,
        truncate: Bool? = nil,
        keepAlive: String? = nil,
        options: ModelOptions? = nil
    ) async throws -> EmbedResponse {
        let request = EmbedRequest(
            model: model,
            input: input,
            truncate: truncate,
            options: options,
            keepAlive: keepAlive
        )

        return try await jsonRequest(
            item: EmbedResponse.self,
            method: "POST",
            path: "/api/embed",
            data: request)
    }
}

// MARK: - Models Methods

extension OllamaInstance {
    public func listLocalModels() async throws -> [LocalModelInfo] {
        let response = try await jsonRequest(item: ListLocalModelsResponse.self, method: "GET", path: "/api/tags")
        return response.models
    }
    
    public func showModelInformation(model: String, verbose: Bool = false) async throws -> ModelInfoResponse {
        let request = ModelInfoRequest(model: model, verbose: verbose)
        
        return try await jsonRequest(
            item: ModelInfoResponse.self,
            method: "POST",
            path: "/api/show",
            data: request)
    }
    
    public func copyModel(source: String, destination: String) async throws {
        let request = [
            "source": source,
            "destination": destination
        ]
        let code: Int = try await self.request(method: "POST", path: "/api/copy", data: request)
        
        switch code {
        case 200:
            return
        case 404:
            throw OllamaError.modelNotFound
        default:
            throw OllamaError.invalidStatusCode
        }
    }
    
    public func deleteModel(model: String) async throws {
        let request = ["model":model]
        let code: Int = try await self.request(method: "DELETE", path: "/api/delete", data: request)
        
        switch code {
        case 200:
            return
        case 404:
            throw OllamaError.modelNotFound
        default:
            throw OllamaError.invalidStatusCode
        }
    }
    
    public func pullModel(model: String, insecure: Bool = false) throws -> AsyncThrowingStream<PullModelResponse, Error> {
        let request = PullModelRequest(model: model,stream: true, insecure: insecure)

        return try jsonStreamRequest(
            item: PullModelResponse.self,
            method: "POST",
            path: "/api/pull",
            data: request)
    }

    public func pullModel(model: String, insecure: Bool = false) async throws -> PullModelResponse {
        let request = PullModelRequest(model: model, stream: false, insecure: insecure)

        return try await jsonRequest(
            item: PullModelResponse.self,
            method: "POST",
            path: "/api/pull",
            data: request)
    }
    
    public func pushModel(model: String, insecure: Bool = false) throws -> AsyncThrowingStream<PushModelResponse, Error> {
        let request = PullModelRequest(model: model,stream: true, insecure: insecure)

        return try jsonStreamRequest(
            item: PushModelResponse.self,
            method: "POST",
            path: "/api/push",
            data: request)
    }
    
    public func pushModel(model: String, insecure: Bool = false) async throws -> PushModelResponse {
        let request = PullModelRequest(model: model, stream: false, insecure: insecure)

        return try await jsonRequest(
            item: PushModelResponse.self,
            method: "POST",
            path: "/api/push",
            data: request)
    }
    
    public func listRuninngModels() async throws -> [Model] {
        let response = try await jsonRequest(
            item: ListRunningModelsResponse.self,
            method: "GET",
            path: "/api/ps")
        return response.models
    }
}

// MARK: - AsyncStreamDelegate

// AsyncStreamDelegate - служит для разделения потока данных предоставляемого
// из URLSession на отдельные строки. Необходим так как Ollama умеет выполнять
// ряд запросов, предоставляя ответ в виде потока данных состоящих из отдельных
// json структур назделенных новыми строками
//
// Мне не очень нравится @unchecked Sendable, однако это единственный способ успокоить XCode
// в этом вопросе, да и с другой стороны, планируется создавать отдельных экземпляры класса
// для отдельных запросов к Ollama так, что это не должно привести к каким-либо ошибкам
final class AsyncStreamDelegate: NSObject, URLSessionDataDelegate, @unchecked Sendable {
    private let continuation: AsyncThrowingStream<Data, Error>.Continuation
    private var buffer = Data()

    init(continuation: AsyncThrowingStream<Data, Error>.Continuation) {
        self.continuation = continuation
        super.init()
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)

        while let range = buffer.range(of: Data([0x0A])) {  // \n
            let lineData = buffer.subdata(in: buffer.startIndex..<range.lowerBound)
            buffer.removeSubrange(buffer.startIndex..<range.upperBound)

            if !lineData.isEmpty {
                continuation.yield(lineData)
            }
        }
    }
}

extension AsyncStreamDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if !buffer.isEmpty {
            continuation.yield(buffer)
        }

        if let error = error {
            continuation.finish(throwing: error)
        } else {
            continuation.finish()
        }
    }
}
