// Simple global function tester
console.log("Global function test loading...");

// Add some simple global functions for testing
window.testFunction1 = function() {
  console.log("Test function 1 works!");
  return "Function 1 executed";
};

window.testFunction2 = function() {
  console.log("Test function 2 works!");
  return "Function 2 executed";
};

console.log("Global functions added:", {
  testFunction1: typeof window.testFunction1,
  testFunction2: typeof window.testFunction2
});

console.log("Global function test loaded successfully");
