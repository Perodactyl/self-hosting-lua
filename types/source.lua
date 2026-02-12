---@meta

---@class Source
---@field name Chunkname
---@field private chunkDisplayName string
---@field sourceText string
---@field sourceTokens LazyStream<Token>
---@field sourceTokenizer Lexer

---@class Error
---@field recoverable boolean If true, parser will continue to try and parse other branches.
---@field type "normal" | "quantifier" | "cause" | "entry" Used to infer which part of an error tree is significant.
---@field message string
---@field children Error[] Child is a lower-level error.
---@field span Span
---@field programInfo? table

---@alias SpanUnit "char" | "token"

---@class Span
---@field start integer
---@field stop integer
---@field source Source
---@field unit SpanUnit
