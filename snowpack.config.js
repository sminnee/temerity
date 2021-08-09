/** @type {import("snowpack").SnowpackUserConfig } */
module.exports = {
  optimize: {
    //bundle: true,
    //minify: true,
  },
  plugins: [
    ["@snowpack/plugin-webpack"],
    ["@jihchi/plugin-rescript"],
  ],
  mount: {
    "public": "/",
    "src": "/dist",
    "test": "/test",
  },
  exclude: [
    '**/node_modules/**/*',
    '**/legacy/**/*',
    "**/*.res",
    "**/*.pegjs",
  ],
  routes: [
    {
      match: 'routes',
      src: '.*',
      dest: '/index.html',
    },
  ],
  env: {
    // API_URL: 'ws://localhost:5000/ws',
  },
};
