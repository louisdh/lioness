CHANGELOG
=========

<details>
<summary>Note: This is in reverse chronological order, so newer entries are added to the top.</summary>

| Contents                   |
| :------------------------- |
| [Lioness 1.0](#lioness-10) |

</details>


Lioness 1.0
-----------

### 2016-12-18

* Lioness now supports functions with arguments. As well as functions that have a return value, with the new ```returns``` keyword. Example:

	```lioness
	func factorial(x) returns {
	
		if x > 1 {
			return x * factorial(x - 1)
		}
	
		return 1
	}
	
	a = factorial(5) // a = 120

	```
		
### 2016-12-11

* Lioness now supports functions. Example:

	```lioness
	a = 2

	do 10 times {
		foo()
	}

	func foo() {
		a += 1
	}

	// a = 12
	```
	
### 2016-12-10

* Lioness now supports ```break``` and ```continue``` statements in loops. 
    
### 2016-12-04

* Lioness now supports ```repeat while``` loops. Example:

	```lioness
	i = 0
	repeat {
		// will be evaluated at least once
		i += 1
	} while i < 10
	```
    
### 2016-11-17

* Lioness now supports ```do times``` loops. Example:

	```lioness
	do 10 times {
		// do something
	}
	```
    
### 2016-11-13

* Lioness now supports ```for``` loops. Example:

	```lioness
	for i = 0, i < 10, i += 1 {
		// do something
	}
	```

### 2016-10-21

* Lioness now supports ```while``` loops. Example:

	```lioness
	while true {
		// do something
	}
	```




