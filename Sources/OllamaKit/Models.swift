//
//  Models.swift
//  OllamaKit
//
//  Created by Дмитрий Папков on 18.06.2025.
//

import Foundation

// MARK: - GenerateCompletionResponse
public struct GenerateCompletionResponse: Codable {
    let model, createdAt, response: String
    let done: Bool
    let context: [Int]?
    let totalDuration, loadDuration, promptEvalCount, promptEvalDuration: Int?
    let evalCount, evalDuration: Int?

    enum CodingKeys: String, CodingKey {
        case model
        case createdAt = "created_at"
        case response, done, context
        case totalDuration = "total_duration"
        case loadDuration = "load_duration"
        case promptEvalCount = "prompt_eval_count"
        case promptEvalDuration = "prompt_eval_duration"
        case evalCount = "eval_count"
        case evalDuration = "eval_duration"
    }
}

// MARK: - GenerateChatCompletionResponse
public struct GenerateChatCompletionResponse: Codable {
    let model: String
    let createdAt: String
    let message: Message
    let done: Bool
    let totalDuration, loadDuration, promptEvalCount, promptEvalDuration: Int?
    let evalCount, evalDuration: Int?

    enum CodingKeys: String, CodingKey {
        case model
        case createdAt = "created_at"
        case message, done
        case totalDuration = "total_duration"
        case loadDuration = "load_duration"
        case promptEvalCount = "prompt_eval_count"
        case promptEvalDuration = "prompt_eval_duration"
        case evalCount = "eval_count"
        case evalDuration = "eval_duration"
    }
}

// MARK: - Message
public struct Message: Codable {
    let role: String
    let content: String
    let thinking: String?
    let images: [Data]?
    let toolCalls: [ToolCall]?
    
    enum CodingKeys: String, CodingKey {
        case role
        case content
        case thinking
        case images
        case toolCalls = "tool_calls"
    }
}

// MARK: - ToolCall
public struct ToolCall: Codable {
    // TODO: - Описать тело структуры
}

// MARK: - ToolItem
public struct ToolItem: Codable {
    let type: ToolItemType
    let function: ToolItemFunction?
    
    enum ToolItemType: Codable {
        case function
    }
}

public struct ToolItemFunction: Codable {
    let name: String
    let description: String
    
    // TODO:
    // Разобраться с тем как передать
    // объект JSONScheema в этом месте
    //let parameters: Decodable & Encodable
}

// MARK: - LocalModelInfo
public struct LocalModelInfo: Codable {
    let name, model, modifiedAt: String
    let size: Int
    let digest: String
    let details: Details

    enum CodingKeys: String, CodingKey {
        case name, model
        case modifiedAt = "modified_at"
        case size, digest, details
    }
}

// MARK: - ModelInfoResponse
public struct ModelInfoResponse: Codable {
    let modelfile, parameters, template: String
    let details: Details
    let modelInfo: ModelInfo
    let capabilities: [String]
    
    enum CodingKeys: String, CodingKey {
            case modelfile, parameters, template, details
            case modelInfo = "model_info"
            case capabilities
        }
}

// MARK: - ModelInfo
public struct ModelInfo: Codable {
    let generalArchitecture: String
    let generalFileType, generalParameterCount, generalQuantizationVersion, llamaAttentionHeadCount: Int
    let llamaAttentionHeadCountKv: Int
    let llamaAttentionLayerNormRMSEpsilon: Double
    let llamaBlockCount, llamaContextLength, llamaEmbeddingLength, llamaFeedForwardLength: Int
    let llamaRopeDimensionCount, llamaRopeFreqBase, llamaVocabSize, tokenizerGgmlBosTokenID: Int
    let tokenizerGgmlEOSTokenID: Int
    //let tokenizerGgmlMerges: [Any?]?
    let tokenizerGgmlModel, tokenizerGgmlPre: String
    //let tokenizerGgmlTokenType, tokenizerGgmlTokens: [Any?]?
    
    enum CodingKeys: String, CodingKey {
        case generalArchitecture = "general.architecture"
        case generalFileType = "general.file_type"
        case generalParameterCount = "general.parameter_count"
        case generalQuantizationVersion = "general.quantization_version"
        case llamaAttentionHeadCount = "llama.attention.head_count"
        case llamaAttentionHeadCountKv = "llama.attention.head_count_kv"
        case llamaAttentionLayerNormRMSEpsilon = "llama.attention.layer_norm_rms_epsilon"
        case llamaBlockCount = "llama.block_count"
        case llamaContextLength = "llama.context_length"
        case llamaEmbeddingLength = "llama.embedding_length"
        case llamaFeedForwardLength = "llama.feed_forward_length"
        case llamaRopeDimensionCount = "llama.rope.dimension_count"
        case llamaRopeFreqBase = "llama.rope.freq_base"
        case llamaVocabSize = "llama.vocab_size"
        case tokenizerGgmlBosTokenID = "tokenizer.ggml.bos_token_id"
        case tokenizerGgmlEOSTokenID = "tokenizer.ggml.eos_token_id"
        //case tokenizerGgmlMerges = "tokenizer.ggml.merges"
        case tokenizerGgmlModel = "tokenizer.ggml.model"
        case tokenizerGgmlPre = "tokenizer.ggml.pre"
        //case tokenizerGgmlTokenType = "tokenizer.ggml.token_type"
        //case tokenizerGgmlTokens = "tokenizer.ggml.tokens"
    }
}

// MARK: - PushModelResponse
public struct PushModelResponse: Codable {
    let status: String
    let digest: String?
    let total: Int?
}

// MARK: - PullModelResponse
public struct PullModelResponse: Codable {
    let status: String
    let digest: String?
    let total, completed: Int?
}

// MARK: - EmbedResponse
public struct EmbedResponse: Codable {
    let model: String
    let embeddings: [[Double]]
    let totalDuration, loadDuration, promptEvalCount: Int

    enum CodingKeys: String, CodingKey {
        case model, embeddings
        case totalDuration = "total_duration"
        case loadDuration = "load_duration"
        case promptEvalCount = "prompt_eval_count"
    }
}


// MARK: - Model
public struct Model: Codable {
    let name, model: String
    let size: Int
    let digest: String
    let details: Details
    let expiresAt: String
    let sizeVRAM: Int

    enum CodingKeys: String, CodingKey {
        case name, model, size, digest, details
        case expiresAt = "expires_at"
        case sizeVRAM = "size_vram"
    }
}

// MARK: - Details
public struct Details: Codable {
    let parentModel, format, family: String
    let families: [String]
    let parameterSize, quantizationLevel: String

    enum CodingKeys: String, CodingKey {
        case parentModel = "parent_model"
        case format, family, families
        case parameterSize = "parameter_size"
        case quantizationLevel = "quantization_level"
    }
}

// MARK: - ModelOptions
public struct ModelOptions: Codable {
    let numKeep, seed, numPredict, topK: Int?
    let topP: Double?
    let minP: Int?
    let typicalP: Double?
    let repeatLastN: Int?
    let temperature, repeatPenalty, presencePenalty: Double?
    let frequencyPenalty: Int?
    let penalizeNewline: Bool?
    let stop: [String]?
    let numa: Bool?
    let numCtx, numBatch, numGPU, mainGPU: Int?
    let useMmap: Bool?
    let numThread: Int?

    enum CodingKeys: String, CodingKey {
        case numKeep = "num_keep"
        case seed
        case numPredict = "num_predict"
        case topK = "top_k"
        case topP = "top_p"
        case minP = "min_p"
        case typicalP = "typical_p"
        case repeatLastN = "repeat_last_n"
        case temperature
        case repeatPenalty = "repeat_penalty"
        case presencePenalty = "presence_penalty"
        case frequencyPenalty = "frequency_penalty"
        case penalizeNewline = "penalize_newline"
        case stop, numa
        case numCtx = "num_ctx"
        case numBatch = "num_batch"
        case numGPU = "num_gpu"
        case mainGPU = "main_gpu"
        case useMmap = "use_mmap"
        case numThread = "num_thread"
    }
}

// MARK: - ListRuningModelsResponse
struct ListRunningModelsResponse: Codable {
    let models: [Model]
}

// MARK: - ListLocalModelsResponse
struct ListLocalModelsResponse: Codable {
    let models: [LocalModelInfo]
}

// MARK: - ModelInfoRequest {
struct ModelInfoRequest: Codable {
    let model: String
    let verbose: Bool
}

// MARK: - PullModelRequest
struct PullModelRequest: Codable {
    let model: String
    let stream: Bool
    let insecure: Bool?
}

// MARK: - GenerateCompletionRequest
struct GenerateCompletionRequest: Codable {
    let stream: Bool
    let model: String
    let prompt: String
    let suffix: String?
    let images: [Data]?
    let think: Bool?
    let format: Data?
    let options: ModelOptions?
    let system: String?
    let template: String?
    let raw: Bool?
    let keepAlive: String?
    
    enum CodingKeys: String, CodingKey {
        case stream, model, prompt, suffix
        case images, think, format, options
        case system, template, raw
        case keepAlive = "keep_alive"
    }
}

// MARK: - GenerateChatCompletionRequest
struct GenerateChatCompletionRequest: Codable {
    let stream: Bool
    let model: String
    let think: Bool?
    let messages: [Message]
    let tools: [ToolItem]?
    let format: Data?
    let options: ModelOptions?
    let keepAlive: String?
    
    
    enum CodingKeys: String, CodingKey {
        case stream, model, think, messages, tools, format, options
        case keepAlive = "keep_alive"
    }
}

// MARK: - EmbedRquest
struct EmbedRequest: Codable {
    let model, input: String
    let truncate: Bool?
    let options: ModelOptions?
    let keepAlive: String?
    
    init(
        model: String,
        input: String,
        truncate: Bool? = nil,
        options: ModelOptions? = nil,
        keepAlive: String? = nil
    ) {
        self.model = model
        self.input = input
        self.keepAlive = keepAlive
        self.truncate = truncate
        self.options = options
    }
    
    enum CodingKeys: String, CodingKey {
        case model, input, truncate, options
        case keepAlive = "keep_alive"
    }
}
