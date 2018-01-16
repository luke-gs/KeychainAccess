# Validation

The generic validation class `Validator` can be used to validate anything that conforms to the `Validatable` protocol. 

`Validatable` objects provide an array of `ValidationRuleSet`. This array represents all the values and their applicable `Specification`s that must be valid in order for the `Validatable` object to be deemed valid.

`ValidationRuleSet` contains three properties and one computed property:

- The `candidate` to be validated.
- An optional `invalidMessage` that will be passed to the `Validator` if an error is thrown.
- The `rules` array, which contains `Specification` objects, which define the rules the object will be judged by.
- The computed property `validityState` runs through the ruleset's `rules` and returns a value of the enum `ValidationState`, either `valid` or `invalid`, the latter including an `errorDescription`.


The `Validator` itself has one func `valid()`, which will ask each rule in the `Validatable` object if it is valid. If it is not, it collects the `errorDescription` and throws a `ValidationError` containing an error of all error messages. If all the rules are valid, the func returns true.





## Sample Usage

```
class Person: Validatable {
	let name = "Larry Barry"
	var email: String? = "larry@gridstone.com.au"
	
	// Validatable Protocol
	var validationRules: [ValidationRuleSet] {
	
		// Specifications can be used simply...
	
		let nameRules = [NotNilSpecification(), NoNumbersSpecification()]
		let nameRuleSet = ValidationRuleSet(candidate: firstName,
											    rules: nameRules,
							           invalidMessage: "Name is not 
							           
							           
		
		
		// OrSpecification can be used for conditional rules.
		// Other conditional specifications exist.
		
		let emailSpecification = OrSpecification(ValidEmailSpecification(), NilSpecification())
		let emailRuleSet = ValidationRuleSet(candidate: email,
											     rules: [emailSpecification],
							            invalidMessage: "Email is not valid")
							           
	
		return [nameRuleSet, emailRuleSet]
	}
}
```

There are a number of Specifications already in existence, but more can be created at any time. See Specification docs for more info.