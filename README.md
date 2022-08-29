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
3. Install proper version of yarn package manager:
   ```
   npm install yarn --global
   ```
   
   This will install 'classic' yarn version 1.x. You need to switch it to latest version:
   ```
   yarn set version berry
   ```
   
   ensure that yarn have version > 3.x:
   ```
   yarn --version
   ```
   
   Install project js dependencies:
   ```
   yarn install
   ```

4. Build assets using yarn
   ```
   yarn build
   ```

   Note: if you want yarn to monitor changes to js files and automatically recompile them launch it with `watch` option:
   ```
   yarn build --watch
   ```

5. Setup and launch DB and other services using Docker (see instruction in development/README.md)


# Javascript handling

This project uses [jsbundling-rails](https://github.com/rails/jsbundling-rails) gem with esbuild for managing JS dependencies.
If you new to this see this [tutorial](https://www.youtube.com/watch?v=qOptalp8zUY) 
