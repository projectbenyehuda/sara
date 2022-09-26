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

4. Build javascript assets using yarn
   ```
   yarn build
   ```

   Note: if you want yarn to monitor changes to js files and automatically recompile them launch it with `watch` option:
   ```
   yarn build --watch
   ```

5. Build stylesheets assets using yarn
   ```
   yarn build:css
   ```

   Note: if you want yarn to monitor changes to css/scss/sass files and automatically recompile them launch it 
   with `watch` option:
   ```
   yarn build:css --watch
   ```

5. Setup and launch DB and other services using Docker (see instruction in development/README.md)

# Managing configuration settings

We expect all settings like database URLs, security keys, etc to be stored in environment variables.
To simplify settings management in development we use [dotenv-rails](https://github.com/bkeepers/dotenv) gem.
In test and developent environments it uses set of configuration files to load environment variables when app starts.
Project repo has two files: `env.test` and `env.development` having environments variables values for corresponding 
environments, assuming that database and other services will be managed by docker.

If your local development setup requires some changes to those files (e.g. you do not want to use docker and prefer to 
host database and other services locally), you don't need to overwrite those files or change other configuration.
Instead you should create personal env file with name `.env.<ENVIRONMENT>.local` and override required values there.
Values specified in `env.<ENVIRONMENT>.local` file take precedence over  values specified in `env.<ENVIRONMENT>`

NOTE: `env.*.local` files are added to `.gitignore` and will not be stored in repo, because those files should be
different for each developer.
