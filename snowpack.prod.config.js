/** @type {import("snowpack").SnowpackUserConfig } */
config = require("./snowpack.config")

module.exports = {
  ...config,

  env: {
    // API_URL: 'wss://api.example.com/ws',
  },
};
