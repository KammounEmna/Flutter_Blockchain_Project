const CivilRegistry = artifacts.require("CivilRegistry");

module.exports = function (deployer) {
  deployer.deploy(CivilRegistry);
};
