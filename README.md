<center><img src="doc-resources/readme/logo.png" style="max-height: 300px; margin-bottom:-55px; margin-top:-50px;"></center>

#<center>The Lioness Programming Language</center>

<center>
[![Swift](https://img.shields.io/badge/Swift-3.0.2-orange.svg?style=flat")](https://developer.apple.com/swift/)
![Platform](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg)
[![Twitter](https://img.shields.io/badge/Twitter-@LouisDhauwe-blue.svg?style=flat)](http://twitter.com/LouisDhauwe)</center>

Lioness is a high-level programming language designed for mathematical purposes. This project includes a lexer, parser, compiler and interpreter. All of these are 100% written in Swift with no depedencies. 

Lioness is inspired by Swift in terms of its syntax, and inspired by shader languages (e.g. GLSL) for its feature set.

The standard library (abbreviated: stdlib) contains basic functions for number manipulation, such as: max/min, ceil, floor, trigonometric functions, etc. However, functions to calculate prime numbers and the like are not considered relevant for the standard library.

## Example
The following calculates factorials recursively:

```
func factorial(x) returns {
	
	if x > 1 {
		return x * factorial(x - 1)
	}
	
	return 1
}

a = factorial(5) // a = 120
```
*More examples can be found [here](Source examples).*

## Xcode file template
Lioness source files can easily be created with Xcode, see [XcodeTemplate.md](XcodeTemplate.md) for instructions.


## Inner workings
Lioness source code is compiled to bytecode, called Scorpion. Scorpion is a simple instruction language, with a very small instruction set (currently 20). <!-- TODO: add list -->


### Lioness pipeline

#### Full pipeline:
| 🛬 ```source code``` | ➡️ | Lexer 	| ➡️ | Parser | ➡️ | Compiler |  ➡️ | Interpreter | ➡️ | ```result``` 🛫 |
|---------------------- |---- |------- |---|-------- |--- |---------- |--- |------------- |--- |-------- |

The following table describes the ```I/O``` of each step in the pipeline:

|             	|       Input       	|       Output      |
|:-----------:	|:-----------------:	|:-----------------:|
|    Lexer    	|    Source code    	|       Tokens      |
|    Parser   	|       Tokens      	|        AST        |
|   Compiler  	|        AST        	| Scorpion Bytecode |
| Interpreter 	| Scorpion Bytecode 	|  Execution result |

*Note: Each step in the pipeline is independent from all others.*

#### Practical workflow:
In practice it is common to want to compile source code once and execute it multiple times. The following pipelines provide this in an efficient way:

*Pipeline 1:*

| 🛬 ```source code``` | ➡️ | Lexer 	| ➡️ | Parser | ➡️ | Compiler |  ➡️ | ```Bytecode``` | ➡️ | ```encode``` 🛫 |
|----------------------|----|------- |---|-------- |----|----------|----|----------------|--- |-------- |

*Pipeline 2:*

| 🛬 ```decode``` | ➡️ | ```Bytecode``` | ➡️ | Interpreter | ➡️ | ```result``` 🛫 |
|-----------------|----|--------------- |-----|------------ |----|-----------------|

The encoding/decoding will typically be followed by writing/reading the bytecode to disk, to enable efficient distribution. 

Generally the performance of the interpreter step is deemed more important than compilation time (pipeline 1). A concrete example of this is compile time code optimization: this will, by definition, slow down compilation time. But the performance gains at runtime are worth it.

## License

TBD