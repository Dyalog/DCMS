# Creating a REST API with Jarvis

## Setting up Jarvis to serve a REST API

```APL
      service ← ⎕NEW #.Jarvis
      service.CodeLocation ← #.MyService
      service.Paradigm ← 'REST'
```

## Creating the request handling APL functions
Your Jarvis server contains a variable **RESTMethods**. This nested matrix of character vectors defines the HTTP methods supported by your service.

```APL
      DCMS.service.RESTMethods
┌───────┬───────┐
│Get    │Get    │
├───────┼───────┤
│Post   │Post   │
├───────┼───────┤
│Put    │Put    │
├───────┼───────┤
│Delete │Delete │
├───────┼───────┤
│Patch  │Patch  │
├───────┼───────┤
│Options│Options│
└───────┴───────┘
```

You can modify **RESTMethods** to either support custom HTTP methods, or to handle a given method via a function with a name of your choosing.

If a request is made using a method not listed in **RESTMethods**, the server will issue a **405 Method Not Allowed** response.

To handle requests, create a monadic, result-returning function for each method you wish to support. The function name is the name in the right-hand column of the **RESTMethods** variable.

The argument to your request-handling function is an HTTPRequest object?

## Allowing cross-origin requests
Since the server requesting resources is different to the server providing them, it will need to allow cross-origin requests.

This is done by appending

```
'access-control-allow-origin' '*'
```

to the response headers.


