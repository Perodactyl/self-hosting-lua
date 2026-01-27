---@meta
---This file is based on section 9 of the lua 5.4 manual, "The Complete Syntax of Lua"

-- Implicit Terminals

--- Name
---@alias Identifier string
--- Numeral
---@alias NumLiteral number
--- LiteralString
---@alias StringLiteral string

-- Tables

do
	--- tableconstructor
	---@alias TableLiteral Field[]

	--- field
	---@class Field
	---@field key Expression
	---@field value Expression
end

-- Chunks and Blocks
do
	---@alias Chunk Block

	---@class Block
	---@field statements Statement[]
	---@field return? ReturnStatement

	--- retstat ::= return [explist] [';']
	---@alias ReturnStatement Expression[] explist
end

-- Statements

do
	--- stat
	---@alias Statement Delimiter | Assignment | FunctionCall | Label | Break | Goto | Do | While | RepeatUntil | If | ForRange | ForIn | FuncDef | LocalFuncDef | LocalAssignment

	--- ';' terminal of stat
	---@class Delimiter
	---@field type "delimiter"

	do
		--- varlist '=' explist
		---@class Assignment
		---@field type "assignment"
		---@field variables Access[] varlist
		---@field values Expression[] explist

		---@class LocalAssignment
		---@field type "localAssignment"
		---@field variables Access[] varlist
		---@field values Expression[] explist

		--- var
		---@alias Access IdentifierAccess | IndexAccess | DotAccess

		--- Name branch of var
		---@class IdentifierAccess
		---@field type "ident"
		---@field inner Identifier

		--- prefixexp '[' exp ']' branch of var
		---@class IndexAccess
		---@field type "index"
		---@field left PrefixExpression
		---@field sub Expression

		--- prefixexp '.' Name branch of var
		---@class DotAccess
		---@field type "dot"
		---@field left PrefixExpression
		---@field sub Identifier
	end

	do
		---@alias FunctionCall FunctionExpressionCall | FunctionMethodCall

		--- prefixexp args branch of functioncall
		---@class FunctionExpressionCall
		---@field type "call"
		---@field callee PrefixExpression
		---@field args Arguments

		--- prefixexp ':' Name args branch of functioncall
		---@class FunctionMethodCall
		---@field type "callMethod"
		---@field class PrefixExpression
		---@field method Identifier
		---@field args Arguments

		--- args
		---@alias Arguments ParenthesisArguments | TableLiteralExpression | StringLiteralExpression
		---@class ParenthesisArguments
		---@field type "parenthesis"
		---@field arguments Expression[] explist
	end

	---@class Label
	---@field type "label"
	---@field name Identifier

	---@class Break
	---@field type "break"

	---@class Goto
	---@field type "goto"
	---@field destination Identifier

	---@class Do
	---@field type "do"
	---@field body Block

	---@class While
	---@field type "while"
	---@field condition Expression
	---@field body Block

	---@class RepeatUntil
	---@field type "repeatUntil"
	---@field body Block
	---@field condition Expression

	do
		---@class If
		---@field type "if"
		---@field condition Expression
		---@field body Block
		---@field elseifs ElseIfBranch[]
		---@field elseBody? Block

		---@class ElseIfBranch
		---@field condition Expression
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
		---@class FuncDef
		---@field type "funcDef"
		---@field name FuncName
		---@field parameters Identifier[]
		---@field rest boolean
		---@field body Block

		---@class LocalFuncDef
		---@field type "localFuncDef"
		---@field name Identifier
		---@field parameters Identifier[]
		---@field rest boolean
		---@field body Block

		--- funcname ::= Name {'.' Name} [':' Name], so a.b:c populates all 3 fields
		---@class FuncName
		---@field base Identifier
		---@field accesses Identifier[]
		---@field method? Identifier
	end
end

-- Expression

do
	---@alias Expression NilLiteralExpression | BoolLiteralExpression | NumLiteralExpression | StringLiteralExpression | TableLiteralExpression | VarArgExpression | FunctionExpression | PrefixExpression | BinaryExpression | UnaryExpression

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

	---@class VarArgExpression
	---@field type "vararg"

	---@class FunctionExpression
	---@field type "funcDef"
	---@field parameters Identifier[]
	---@field body Block

	do
		---@alias PrefixExpression PrefixAccessExpression | PrefixCallExpression | PrefixGroupExpression

		---@class PrefixAccessExpression
		---@field type "prefix"
		---@field subtype "access"
		---@field key Access

		---@class PrefixCallExpression
		---@field type "prefix"
		---@field subtype "call"
		---@field call FunctionCall

		---@class PrefixGroupExpression
		---@field type "prefix"
		---@field subtype "group"
		---@field inner Expression
	end

	do
		---@class BinaryExpression
		---@field type "binary"
		---@field left Expression
		---@field operator BinaryOperator
		---@field right Expression

		---@alias BinaryOperator "+" | "-" | "*" | "/" | "//" | "^" | "%" | "&" | "~" | "|" | ">>" | "<<" | ".." | "<" | "<=" | ">" | ">=" | "==" | "~=" | "and" | "or"
	end

	do
		---@class UnaryExpression
		---@field type "unary"
		---@field operator UnaryOperator
		---@field right Expression

		---@alias UnaryOperator "-" | "not" | "#" | "~"
	end
end
