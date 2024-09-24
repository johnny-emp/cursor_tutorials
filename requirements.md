# Reflective Token Contract Requirements

## Development Environment
- We will be using Foundry's Forge for smart contract development and testing.

## Testing
- Comprehensive test coverage will be implemented using Forge's testing framework.
- We aim for high test coverage to ensure the reliability and security of the contract.

## Library Development
- A separate library will be developed for complex computations.
- This library will handle calculations related to reflections, tax distributions, and other mathematical operations.

## Key Requirements
1. Implement a settable token address functionality.
2. Develop configurable buy and sell tax mechanisms.
3. Create a reflection system for distributing a portion of taxes to token holders.
4. Design a flexible, user-defined function for allocating the remaining tax portion.
5. Ensure proper access control for sensitive functions (e.g., tax rate modifications).
6. Implement events for important state changes and actions.

## Security Considerations
- Implement safeguards against excessive taxation.
- Ensure the user-defined function is secure and doesn't introduce vulnerabilities.
- Conduct thorough testing of all mathematical operations to prevent overflow/underflow issues.

## Documentation
- Provide clear documentation for all functions, events, and state variables.
- Include usage examples and deployment instructions in the README.