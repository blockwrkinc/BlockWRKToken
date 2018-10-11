const { expectThrow } = require('openzeppelin-solidity/test/helpers/expectThrow');
const { EVMRevert } = require('openzeppelin-solidity/test/helpers/EVMRevert');

const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

require('chai').should();

function shouldBehaveLikeAuthorizable (accounts) {
    describe('as an ownable', function () {
        it('should have an owner', async function () {
          const owner = await this.authorizable.owner();
          owner.should.not.eq(ZERO_ADDRESS);
        });

        it('should allow owner to add', async function() {
            const authorized = accounts[1];
            const owner = await this.authorizable.owner();
            this.authorizable.addAuthorized(authorized, { from: owner });
            const result = await this.authorizable.isAuthorized(authorized, { from: owner });
            result.should.eq(true);
        });

        it('should allow owner to remove', async function() {
            const authorized = accounts[1];
            const owner = await this.authorizable.owner();
            this.authorizable.removeAuthorized(authorized, { from: owner });
            const result = await this.authorizable.isAuthorized(authorized, { from: owner });
            result.should.eq(false);
        })

        it('should prevent non-owners from adding', async function () {
            const other = accounts[2];
            const owner = await this.authorizable.owner();
            owner.should.not.eq(other);
            await expectThrow(this.authorizable.addAuthorized(other, { from: other }), EVMRevert);
        });

        it('should prevent non-owners from removing', async function () {
            const other = accounts[2];
            const owner = await this.authorizable.owner();
            owner.should.not.eq(other);
            await expectThrow(this.authorizable.removeAuthorized(owner, { from: other }), EVMRevert);
        });
    });
}

module.exports = {
  shouldBehaveLikeAuthorizable,
};
