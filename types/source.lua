---@meta

---@class Source
---@field name Chunkname
---@field private chunkDisplayName string
---@field sourceText string
---@field sourceTokens LazyStream<Token>

---@class Error
---@field recoverable boolean If true, parser will continue to try and parse other branches.
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
