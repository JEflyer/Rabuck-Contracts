require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan")
require("hardhat-contract-sizer")
require("hardhat-gas-reporter")
require("solidity-coverage")
require("hardhat-deploy")
require("dotenv").config()

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  networks: {
    rinkeby: {
      url: process.env.RINKEBY_URL,
      chainId: 4,
      accounts: [
        process.env.PRIVATE_KEY_DEPLOYER,
        process.env.PRIVATE_KEY_USER_2,
        process.env.PRIVATE_KEY_USER_3,
        process.env.PRIVATE_KEY_USER_4,
        process.env.PRIVATE_KEY_USER_5,
        process.env.PRIVATE_KEY_USER_6,
        process.env.PRIVATE_KEY_USER_7,
        process.env.PRIVATE_KEY_USER_8,
      ].filter((x) => x !== undefined),
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERCAN_API_KEY,
  },
  namedAccounts: {
    deployer: {
      default: 0,
      4: 0,
    },
    user2: {
      default: 1,
      4: 1,
    },
    user3: {
      default: 2,
      4: 2,
    },
    user4: {
      default: 3,
      4: 3,
    },
    user5: {
      default: 4,
      4: 4,
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.8.7",
      },
    ],
  },
  mocha: {
    timeout: 10000000,
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    Strict: true,
  },
};
