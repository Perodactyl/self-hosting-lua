---@meta
---This file is based on section 9 of the lua 5.4 manual, "The Complete Syntax of Lua"

-- Implicit Terminals

--- Name
---@alias Identifier IdentifierToken
--- Numeral
---@alias NumLiteral NumberToken
--- LiteralString
---@alias StringLiteral StringToken

-- Tables

do
	--- tableconstructor
	---@class TableLiteral
	---@field type "table"
	---@field openBrace SymbolToken
	---@field closeBrace SymbolToken
	---@field fields Sequence<Field, SymbolToken>

	---@class AutoFieldTokens
	---@field type "auto"
	---@class IdentifierFieldTokens
	---@field type "identifier"
	---@field assign AssignToken
	---@class ExpressionFieldTokens
	---@field openBracket SymbolToken
	---@field closeBracket SymbolToken
	---@field assign AssignToken

	--- field
	---@class Field
	---@field tokens AutoFieldTokens | IdentifierFieldTokens | ExpressionFieldTokens
	---@field key Expression
	---@field value Expression
end

-- Chunks and Blocks
do
	---@alias Chunk Block

	---@class Block
	---@field statements Statement[]
	---@field returnStatement? ReturnStatement
	---@field scope? Scope

	--- retstat ::= return [explist] [';']
	---@class ReturnStatement
	---@field returnToken KeywordToken
	---@field expressions explist
end

-- Statements

---@class Sequence<T,S>: { values: T[], separators: S[] }
---@alias varlist Sequence<Access, SymbolToken>
---@alias explist Sequence<Expression, SymbolToken>

do
	--- stat
	---@alias Statement Delimiter | Assignment | FunctionCall | Label | Break | Goto | Do | While | RepeatUntil | If | ForRange | ForIn | FuncDef

	--- ';' terminal of stat
	---@class Delimiter
	---@field type "delimiter"
	---@field token SymbolToken

	do
		--- varlist '=' explist
		---@class Assignment
		---@field type "assignment"
		---@field localToken KeywordToken | nil
		---@field variables varlist
		---@field right {assign: AssignToken, values: explist} | nil

		--- var
		---@alias Access PrefixAccessExpression
	end

	do
		---@alias FunctionCall FunctionExpressionCall

		--- prefixexp args branch of functioncall
		---@class FunctionExpressionCall
		---@field type "call"
		---@field callee PrefixExpression
		---@field method {token:SymbolToken, name:Identifier}
		---@field args Arguments

		--- args
		---@alias Arguments ParenthesisArguments | TableLiteralExpression | StringLiteralExpression

		---@class ParenthesisArguments
		---@field type "parenthesis"
		---@field arguments explist
		---@field openParen SymbolToken
		---@field closeParen SymbolToken
	end

	---@class Label
	---@field type "label"
	---@field openToken SymbolToken
	---@field closeToken SymbolToken
	---@field name Identifier

	---@class Break
	---@field type "break"
	---@field token KeywordToken

	---@class Goto
	---@field type "goto"
	---@field token KeywordToken
	---@field destination Identifier

	---@class Do
	---@field type "do"
	---@field openToken KeywordToken
	---@field closeToken KeywordToken
	---@field body Block

	---@class While
	---@field type "while"
	---@field whileToken KeywordToken
	---@field condition Expression
	---@field doToken KeywordToken
	---@field body Block
	---@field endToken KeywordToken

	---@class RepeatUntil
	---@field type "repeatUntil"
	---@field repeatToken KeywordToken
	---@field body Block
	---@field untilToken KeywordToken
	---@field condition Expression

	do
		---@class If
		---@field type "if"
		---@field ifToken KeywordToken
		---@field condition Expression
		---@field thenToken KeywordToken
		---@field body Block
		---@field elseifs ElseIfBranch[]
		---@field elsePart? {token: KeywordToken, body: Block}
		---@field endToken KeywordToken

		---@class ElseIfBranch
		---@field elseifToken KeywordToken
		---@field condition Expression
		---@field thenToken KeywordToken
		---@field body Block
	end

	---@class ForRange
	---@field type "forRange"
	---@field iterVar Identifier
	---@field min Expression
	---@field max Expression
	---@field step? Expression
	---@field body Block

	---@class ForIn
	---@field type "forIn"
	---@field variables Identifier[]
	---@field expressions Expression[]
	---@field body Block

	do
		---@class FuncImpl
		---@field openParen SymbolToken
		---@field closeParen SymbolToken
		---@field rest SymbolToken
		---@field endToken KeywordToken
		---@field parameters varlist
		---@field body Block

		---@class FuncDef
		---@field type "funcDef"
		---@field name FuncName
		---@field impl FuncImpl
		---@field functionToken KeywordToken
		---@field localToken KeywordToken | nil

		--- funcname ::= Name {'.' Name} [':' Name], so a.b:c populates all 3 fields
		---@class FuncName
		---@field base PrefixIdentifierAccessExpression
		---@field accesses Identifier[]
		---@field method? Identifier
	end
end

-- Expression

do
	---@alias Expression NilLiteralExpression | BoolLiteralExpression | NumLiteralExpression | StringLiteralExpression | TableLiteralExpression | VarArgExpression | FunctionExpression | PrefixExpression | BinaryExpression | UnaryExpression

	--[[
	---@class NilLiteralExpression
	---@field type "nil"

	---@class BoolLiteralExpression
	---@field type "bool"
	---@field value boolean

	---@class NumLiteralExpression
	---@field type "number"
	---@field value NumLiteral

	---@class StringLiteralExpression
	---@field type "string"
	---@field value StringLiteral

	---@class TableLiteralExpression
	---@field type "table"
	---@field value TableLiteral
	---]]
	---@alias NilLiteralExpression NilToken
	---@alias BoolLiteralExpression BooleanToken
	---@alias NumLiteralExpression NumLiteral
	---@alias StringLiteralExpression StringLiteral
	---@alias TableLiteralExpression TableLiteral

	---@class VarArgExpression
	---@field type "vararg"
	---@field token SymbolToken

	---@class FunctionExpression
	---@field type "funcDef"
	---@field functionToken KeywordToken
	---@field impl FuncImpl

	do
		---@alias PrefixExpression PrefixAccessExpression | PrefixCallExpression | PrefixGroupExpression

		---@alias PrefixAccessExpression PrefixIdentifierAccessExpression | PrefixIndexAccessExpression | PrefixDotAccessExpression

		---@class PrefixCallExpression
		---@field type "prefix"
		---@field subtype "call"
		---@field call FunctionCall

		---@class PrefixGroupExpression
		---@field type "prefix"
		---@field subtype "group"
		---@field inner Expression
		---@field openParen SymbolToken
		---@field closeParen SymbolToken

		--- Name branch of var
		---@class PrefixIdentifierAccessExpression
		---@field type "prefix"
		---@field subtype "identifier"
		---@field inner Identifier
		---@field binding? ScopeMember

		--- prefixexp '[' exp ']' branch of var
		---@class PrefixIndexAccessExpression
		---@field type "prefix"
		---@field subtype "index"
		---@field left PrefixExpression
		---@field sub Expression

		--- prefixexp '.' Name branch of var
		---@class PrefixDotAccessExpression
		---@field type "prefix"
		---@field subtype "dot"
		---@field left PrefixExpression
		---@field sub Identifier
	end

	do
		---@class BinaryExpression
		---@field type "binary"
		---@field left Expression
		---@field operator OperatorToken
		---@field right Expression

		---@alias BinaryOperator "+" | "-" | "*" | "/" | "//" | "^" | "%" | "&" | "~" | "|" | ">>" | "<<" | ".." | "<" | "<=" | ">" | ">=" | "==" | "~=" | "and" | "or"
	end

	do
		---@class UnaryExpression
		---@field type "unary"
		---@field operator OperatorToken
		---@field right Expression

		---@alias UnaryOperator "-" | "not" | "#" | "~"
	end
end
