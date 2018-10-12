//var BlockWRKICO = artifacts.require("./BlockWRKICO");
var BlockWRKToken = artifacts.require("./BlockWRKToken");

module.exports = function(deployer) {
    deployer.deploy(BlockWRKToken);
};
