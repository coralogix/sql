/*
MySQL (Positive Technologies) grammar
The MIT License (MIT).
Copyright (c) 2015-2017, Ivan Kochurkin (kvanttt@gmail.com), Positive Technologies.
Copyright (c) 2017, Ivan Khudyashev (IHudyashov@ptsecurity.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

parser grammar OpenDistroSQLParser;

import OpenDistroSQLIdentifierParser;

options { tokenVocab=OpenDistroSQLLexer; }


// Top Level Description

//    Root rule
root
    : sqlStatement? SEMI? EOF
    ;

//    Only SELECT
sqlStatement
    : dmlStatement
    ;

dmlStatement
    : selectStatement
    ;


// Data Manipulation Language

//    Primary DML Statements

selectStatement
    : querySpecification                                 #simpleSelect
    ;


//    Select Statement's Details

querySpecification
    : selectClause
      fromClause?
    ;

selectClause
    : SELECT selectElements
    ;

selectElements
    : (star=STAR | selectElement) (COMMA selectElement)*
    ;

selectElement
    : expression (AS? alias)?
    ;

fromClause
    : FROM tableName
      (whereClause)?
    ;

whereClause
    : WHERE expression
    ;

//    Literals

constant
    : stringLiteral             #string
    | sign? decimalLiteral      #signedDecimal
    | sign? realLiteral         #signedReal
    | booleanLiteral            #boolean
    | datetimeLiteral           #datetime
    | nullLiteral               #null
    // Doesn't support the following types for now
    //| BIT_STRING
    //| NOT? nullLiteral=(NULL_LITERAL | NULL_SPEC_LITERAL)
    //| LEFT_BRACE dateType=(D | T | TS | DATE | TIME | TIMESTAMP) stringLiteral RIGHT_BRACE
    ;

decimalLiteral
    : DECIMAL_LITERAL | ZERO_DECIMAL | ONE_DECIMAL | TWO_DECIMAL
    ;

stringLiteral
    : STRING_LITERAL
    ;

booleanLiteral
    : TRUE | FALSE
    ;

realLiteral
    : REAL_LITERAL
    ;

sign
    : PLUS | MINUS
    ;

nullLiteral
    : NULL_LITERAL
    ;

// Date and Time Literal, follow ANSI 92
datetimeLiteral
    : dateLiteral
    | timeLiteral
    | timestampLiteral
    ;

dateLiteral
    : DATE date=stringLiteral
    ;

timeLiteral
    : TIME time=stringLiteral
    ;

timestampLiteral
    : TIMESTAMP timestamp=stringLiteral
    ;

//    Expressions, predicates

// Simplified approach for expression
expression
    : NOT expression                                                #notExpression
    | left=expression AND right=expression                          #andExpression
    | left=expression OR right=expression                           #orExpression
    | predicate                                                     #predicateExpression
    ;

predicate
    : expressionAtom                                                #expressionAtomPredicate
    | left=predicate comparisonOperator right=predicate             #binaryComparisonPredicate
    | predicate IS nullNotnull                                      #isNullPredicate
    | left=predicate NOT? LIKE right=predicate                      #likePredicate
    ;

expressionAtom
    : constant                                                      #constantExpressionAtom
    | columnName                                                    #fullColumnNameExpressionAtom
    | functionCall                                                  #functionCallExpressionAtom
    | LR_BRACKET expression RR_BRACKET                              #nestedExpressionAtom
    | left=expressionAtom mathOperator right=expressionAtom         #mathExpressionAtom
    ;

mathOperator
    : PLUS | MINUS | STAR | DIVIDE | MODULE
    ;

comparisonOperator
    : '=' | '>' | '<' | '<' '=' | '>' '='
    | '<' '>' | '!' '='
    ;

nullNotnull
    : NOT? NULL_LITERAL
    ;

functionCall
    : scalarFunctionName LR_BRACKET functionArgs? RR_BRACKET        #scalarFunctionCall
    ;

scalarFunctionName
    : mathematicalFunctionName
    | dateTimeFunctionName
    ;

mathematicalFunctionName
    : ABS | CEIL | CEILING | CONV | CRC32 | E | EXP | FLOOR | LN | LOG | LOG10 | LOG2 | MOD | PI | POW | POWER
    | RAND | ROUND | SIGN | SQRT | TRUNCATE
    | trigonometricFunctionName
    ;

trigonometricFunctionName
    : ACOS | ASIN | ATAN | ATAN2 | COS | COT | DEGREES | RADIANS | SIN | TAN
    ;

dateTimeFunctionName
    : DAYOFMONTH
    ;

functionArgs
    : (functionArg (COMMA functionArg)*)?
    ;

functionArg
    : expression
    ;

