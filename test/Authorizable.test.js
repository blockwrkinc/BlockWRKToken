const { shouldBehaveLikeAuthorizable } = require('./Authorizable.behaviour');

const Authorizable = artifacts.require('Authorizable');

contract('Authorizable', function (accounts) {
  beforeEach(async function () {
    this.authorizable = await Authorizable.new();
  });

  shouldBehaveLikeAuthorizable(accounts);
});
