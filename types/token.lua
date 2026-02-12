---@meta

---@class TokenBase
---@field span Span
---@field index integer
---@field supertype "token"
---@field type string

---@class NilToken: TokenBase
---@field type "nil"

---@class BooleanToken: TokenBase
---@field type "boolean"
---@field value string

---@class StringToken: TokenBase
---@field type "string"
---@field value string

---@class NumberToken: TokenBase
---@field type "number"
---@field value number

---@class KeywordToken: TokenBase
---@field type "keyword"
---@field value Keyword

---@class OperatorToken: TokenBase
---@field type "operator"
---@field value Operator

---@class SymbolToken: TokenBase
---@field type "symbol"
---@field value Symbol

---@class AssignToken: TokenBase
---@field type "assign"
---@field value Assign

---@class IdentifierToken: TokenBase
---@field type "identifier"
---@field value string

---@alias Token NilToken | BooleanToken | StringToken | NumberToken | KeywordToken | OperatorToken | SymbolToken | AssignToken | IdentifierToken

---@alias Operator UnaryOperator | BinaryOperator

---@alias Keyword "break" | "do" | "else" | "elseif" | "end" | "for" | "function" | "goto" | "if" | "in" | "local" | "repeat" | "return" | "then" | "until" | "while" | "local"

---@alias Symbol "{" | "}" | "(" | ")" | "[" | "]" | "," | "." | ":" | "::" | ";" | "..."

---@alias Assign "="

