
**OWASP OWTF Tornado-React Demo** is a sample repository to demonstrate how I will integrate present tornado app with my UI created using ReactJS

Requirements
===

Presently nothing more is needed to run the demo. OWTF environment will work for this demo.

##### For Development:

> **Note**: We will be using nvm to install latest version of nodejs. As apt-get installs older version.

Follow the following steps to install nvm:

- curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.1/install.sh | bash

- nvm install node

- nvm alias default node

- npm install -g webpack

- cd owtf-tornado-react-demo

- npm install


Above steps will install node and will setup environment for development of owtf reactJS app.

Usage
===

##### For Demo:

- Nothing needs to be done. Just run application in same owtf environment

##### For Building:

- $ **webpack** : this will create a bundle.js file in /includes/js/ (Written in webpack.config.js)

##### For developing:

- Use **/includes/src/** directory for developing owtf reactJS app.




