# Discuss

This is a web application for creating topics with Phoenix. 
A topic has a name and a body, and can have many comments made by various users. 
User authentication is handled by UeberAuth with users' GitHub accounts.
Each topic has an "Identicon" created from its name as an avatar.
Comments are made with use of web sockets.

### Installing

This app requires Postgresql and your own API keys from UeberAuth (see .env.example for a template).
Before you start the server, run 

```
source ./.env
```

and 

```
mix deps.get
```

### Starting the server
To start the server on default port (80), run

```
mix phx.server
```

### Running the tests

To run the tests, run

```
mix test
```

## Author

Alisa Berdichevskaia [Amber-Cloud](https://github.com/Amber-Cloud)

## Acknowledgments

This project was based on a project from [Stephen Grider](https://github.com/StephenGrider)'s course ["The Complete Elixir and Phoenix Bootcamp"](https://www.udemy.com/course/the-complete-elixir-and-phoenix-bootcamp-and-tutorial/).