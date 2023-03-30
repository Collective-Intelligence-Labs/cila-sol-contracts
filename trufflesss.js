module.exports = {
    networks: {
      development: {
        host: "127.0.0.1",     // Localhost (default: none)
        port: 7545,            // Standard Ethereum port (default: none)
        network_id: "*",       // Any network (default: none)
      },
    },
    solc: {
      optimizer: {
          enabled: true,
          runs: 200
      }
  },
    compilers: {
      solc: {
        version: "0.8.7",     // Use the specified version of the Solidity compiler
      },
    },
  };