//
//  README.md
//  RecipeNetworking
//
//  Created by Nitin George on 01/03/2025.
//

# **RecipeNetworking**

The **`RecipeNetworking`** provides a simple, reusable API wrapper around the network back end, facilitating data retrieval. It abstracts the complexity of networking and parsing, offering a clean interface for developers to interact with API endpoints.

---

## **Features**

- **Fetch Recipes**: Simplified methods to retrieve recipes from a network back end. used Async/await.
- **Error Handling**: Robust error handling for network issues and decoding failures.

## **Usage**

### **Creating an `RecipeService` Instance**

To interact with the network or mock data, use the `RecipeServiceFactory` to create an instance of `RecipeService`:

```swift
import RecipeNetworking

let recipeService = RecipeServiceFactory.createRecipeService()
```

---

### **Fetching Recipes**

Once you have an `RecipeService` instance, call its `fetchRecipes` method to fetch data:

---

## **Error Handling**

The `NewsNetworking` provides a `NetworkError` enum to classify and handle errors:

- **`invalidURL`**: Indicates an invalid or malformed URL.
- **`responseError`**: Indicates a non-200 HTTP response.
- **`failedToDecode`**: Represents a decoding failure with an associated error.
- **`unKnown`**: For unexpected errors.

#### **Example**
```swift
switch error {
case NetworkError.invalidURL:
    print("The URL is invalid.")
case NetworkError.responseError:
    print("There was an issue with the response.")
case NetworkError.failedToDecode(let decodingError):
    print("Failed to decode: \(decodingError)")
case NetworkError.unKnown:
    print("An unknown error occurred.")
default:
    print("Unexpected error: \(error)")
}
```
---

## **Architecture**

### **Main Components**

1. **`RecipeServiceFactory`**:
   - Creates and configures instances of `RecipeService`.

2. **`RecipeServiceImpl`**:
   - Implements the business logic for fetching recipes from the network.

3. **`RecipeRepository`**:
   - Abstracts the underlying data source (network or mock).

4. **`ServiceParser`**:
   - Handles parsing of raw data into `Decodable` models.

---

### **Model Concept**

The RecipeNetworking follows the Adapter Design Pattern to separate concerns between raw data from the network, business logic, and UI presentation. This approach ensures scalability, reusability, and clean architecture.

#### **Data Flow**
    1.    **API Response → DTO (RecipeDTO)**: Raw JSON data from the API is parsed into a structured DTO.
    2.    **`DTO → Domain Model (RecipeDomain)**: Business logic and validation are applied while mapping DTO to domain model.
    3.    **`Domain Model → View Model (Recipe)**: The domain model is further formatted and transformed into a view-specific model for rendering.
    
---
