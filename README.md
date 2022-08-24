# sara
SARA: Smart Automatic Research Assistant

# Development setup

In Ubuntu

1. Install required binary dependencies
    ```
    sudo apt-get install libmysqlclient-dev
    ```

2. Install proper NodeJS version, we recommend using [NVM](https://github.com/nvm-sh/nvm):
    ```
    nvm install lts/gallium
    nvm use 16.17.0
    ```
   You may need to close and reopen terminal window after nvm installation

3. Setup and launch DB and other services using Docker (see instruction in development/README.md)

4. 

# Javascript handling

This project uses [jsbundling-rails](https://github.com/rails/jsbundling-rails) gem with esbuild for managing JS dependencies.
If you new to this see this [tutorial](https://www.youtube.com/watch?v=qOptalp8zUY) 
