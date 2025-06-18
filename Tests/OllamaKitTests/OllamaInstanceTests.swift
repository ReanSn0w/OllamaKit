import Testing
import XCTest
import Foundation
@testable import OllamaKit

struct OllamaInstanceTests {
    let instance: OllamaInstance = .init(URL(string: "http://192.168.3.24:11434")!, session: .default)
    let modelName: String = "nomic-embed-text"
    let generateModel: String = "qwen3:0.6b"
    
    
    @Test("Generate Completion Stream") func generateCompletionStream() async throws {
        _ = try await instance.pullModel(model: generateModel)
        var count: Int = 0
        
        for try await data in try instance.generateCompletion(
            model: generateModel,
            prompt: "Привет, как дела?"
        ) {
            count += 1
            print("Is Done: \(data.done), Current Token: \(data.response)")
        }
        
        #expect(count > 0)
    }
    
    @Test("Generate Completion Non-Stream") func generateCompletion() async throws {
        _ = try await instance.pullModel(model: generateModel)
        
        let response = try await instance.generateCompletion(
            model: generateModel,
            prompt: "Привет, как дела?")
        
        #expect(!response.response.isEmpty)
        #expect(response.done)
    }
    
    @Test("Generate Chat Completion Stream") func generateChatCompletionStream() async throws {
        _ = try await instance.pullModel(model: generateModel)
        var count: Int = 0
        
        for try await data in try instance.generateChatCompletion(
            model: generateModel,
            messages: [
                .init(
                    role: "user",
                    content: "Привет, как дела?",
                    thinking: nil,
                    images: nil,
                    toolCalls: nil)
            ]
        ) {
            count += 1
            print("Is Done: \(data.done), Current Token: \(data.message.content)")
        }
        
        #expect(count > 0)
    }
    
    @Test("Generate Chat Completion Non-Stream") func generateChatCompletion() async throws {
        _ = try await instance.pullModel(model: generateModel)
        
        let response = try await instance.generateChatCompletion(
            model: generateModel,
            messages: [
                .init(
                    role: "user",
                    content: "Привет, как дела?",
                    thinking: nil,
                    images: nil,
                    toolCalls: nil)
            ])
        
        #expect(!response.message.content.isEmpty)
        #expect(response.done)
    }
    
    @Test("Show Model Info") func showModelInformation() async throws {
        
    }
    
    @Test("Copy Model") func copyModel() async throws {
        _ = try await instance.pullModel(model: modelName)
        try await instance.copyModel(source: modelName, destination: "fork_" + modelName)
        try await instance.deleteModel(model: "fork_" + modelName)
    }
    
    @Test("Copy Unavaliable Model") func copyUnavaliableModel() async throws {
        do {
            try await instance.copyModel(source: "fork_" + modelName, destination: "fork2_" + modelName)
        } catch {
            #expect(error as? OllamaError == .modelNotFound)
        }
    }
    
    @Test("Delete Model") func deleteModel() async throws {
        _ = try await instance.pullModel(model: modelName)
        try await instance.copyModel(source: modelName, destination: "fork_" + modelName)
        try await instance.deleteModel(model: "fork_" + modelName)
    }
    
    @Test("Delete Unavaliable Model") func deleteUnavaliableModel() async throws {
        do {
            try await instance.deleteModel(model: "fork_unavaliable_" + modelName)
        } catch {
            #expect(error as? OllamaError == .modelNotFound)
        }
    }
    
    @Test("Pull Model Stream") func pullModelStream() async throws {
        do {
            try await instance.deleteModel(model: modelName)
        } catch {
            print("model not pulled yet")
        }
        
        var count: Int = 0
        
        for try await data in try instance.pullModel(model: modelName)  {
            count += 1
            print("Status: \(data.status), Progress: \(data.completed ?? 0) / \(data.total ?? 0)")
        }
        
        #expect(count > 0)
    }
    
    @Test("Pull Model Non-Stream") func pullModelNonStream() async throws {
        do {
            try await instance.deleteModel(model: modelName)
        } catch {
            print("model not pulled yet")
        }
        
        _ = try await instance.pullModel(model: modelName)
    }
    
    @Test("Generate Text Embedding") func embedText() async throws {
        _ = try await instance.pullModel(model: modelName)
        
        let text = "Hello, world!"
        
        let result = try await instance.generateEmbeddings(model: modelName, input: text)
        
        #expect(!result.embeddings.isEmpty)
        #expect(!result.embeddings[0].isEmpty)
        #expect(result.model == modelName)
        #expect(result.loadDuration > 1)
        #expect(result.promptEvalCount > 1)
        #expect(result.totalDuration > 1)
    }
    
    @Test("List Running Ollama Models") func listRunningModels() async throws {
        _ = try await instance.listRuninngModels()
    }
    
    @Test("Get Ollama Instance Version") func getOllamaVersion() async throws {
        let version = try await instance.getOllamaVersion()
        print("Ollama version: \(version)")
    }
}
