const { assertRevert } = require('openzeppelin-solidity/test/helpers/assertRevert');
const TaxedTokenMock = artifacts.require('TaxedTokenMock');

contract('TaxedToken', function ([owner, recipient, feeAccount, anotherAccount]) {
    const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

    beforeEach(async function () {
        this.token = await TaxedTokenMock.new(owner, 1000, feeAccount, 1);
    });

    describe('transfer', function () {
        describe('when the recipient is not the zero address', function () {
            const to = recipient;

            describe('when the sender does not have enough balance', function () {
                const amount = 1001;

                it('reverts', async function () {
                    await assertRevert(this.token.transfer(to, amount, { from: owner }));
                });
            });

            describe('when the sender has enough balance', function () {
                const amount = 100;

                it('transfers the requested amount', async function () {
                    await this.token.transfer(to, amount, { from: owner });
                    const ownerBalance = await this.token.balanceOf(owner);
                    assert.equal(ownerBalance, 900);
                    const recipientBalance = await this.token.balanceOf(to);
                    assert.equal(recipientBalance, 99);
                    const feeAccountBalance = await this.token.balanceOf(feeAccount);
                    assert.equal(feeAccountBalance, 1);
                });

                it('emits the transfer events', async function () {
                    const { logs } = await this.token.transfer(to, amount, { from: owner });
                    assert.equal(logs.length, 2);
                    assert.equal(logs[0].event, 'Transfer');
                    assert.equal(logs[0].args.from, owner);
                    assert.equal(logs[0].args.to, to);
                    assert(logs[0].args.value.eq(99));
                    assert.equal(logs[1].event, 'Transfer');
                    assert.equal(logs[1].args.from, owner);
                    assert.equal(logs[1].args.to, feeAccount);
                    assert(logs[1].args.value.eq(1));
                });
            });
        });

        describe('when the recipient is the zero address', function () {
          const to = ZERO_ADDRESS;

          it('reverts', async function () {
            await assertRevert(this.token.transfer(to, 100, { from: owner }));
          });
        });
    });

    describe('transfer from', function () {
      const spender = recipient;

      describe('when the recipient is not the zero address', function () {
        const to = anotherAccount;

        describe('when the spender has enough approved balance', function () {
          beforeEach(async function () {
            await this.token.approve(spender, 100, { from: owner });
          });

          describe('when the owner has enough balance', function () {
            const amount = 100;

            it('transfers the requested amount', async function () {
              await this.token.transferFrom(owner, to, amount, { from: spender });
              const senderBalance = await this.token.balanceOf(owner);
              assert.equal(senderBalance, 900);
              const recipientBalance = await this.token.balanceOf(to);
              assert.equal(recipientBalance, 99);
              const feeAccountBalance = await this.token.balanceOf(feeAccount);
              assert.equal(feeAccountBalance, 1);
            });

            it('decreases the spender allowance', async function () {
              await this.token.transferFrom(owner, to, amount, { from: spender });
              const allowance = await this.token.allowance(owner, spender);
              assert(allowance.eq(0));
            });

            it('emits the transfer events', async function () {
              const { logs } = await this.token.transferFrom(owner, to, amount, { from: spender });
              assert.equal(logs.length, 2);
              assert.equal(logs[0].event, 'Transfer');
              assert.equal(logs[0].args.from, owner);
              assert.equal(logs[0].args.to, to);
              assert(logs[0].args.value.eq(99));
              assert.equal(logs[1].event, 'Transfer');
              assert.equal(logs[1].args.from, owner);
              assert.equal(logs[1].args.to, feeAccount);
              assert(logs[1].args.value.eq(1));
            });
          });

          describe('when the owner does not have enough balance', function () {
            const amount = 1001;

            it('reverts', async function () {
              await assertRevert(this.token.transferFrom(owner, to, amount, { from: spender }));
            });
          });
        });

        describe('when the spender does not have enough approved balance', function () {
          beforeEach(async function () {
            await this.token.approve(spender, 99, { from: owner });
          });

          describe('when the owner has enough balance', function () {
            const amount = 100;

            it('reverts', async function () {
              await assertRevert(this.token.transferFrom(owner, to, amount, { from: spender }));
            });
          });

          describe('when the owner does not have enough balance', function () {
            const amount = 1001;

            it('reverts', async function () {
              await assertRevert(this.token.transferFrom(owner, to, amount, { from: spender }));
            });
          });
        });
      });

      describe('when the recipient is the zero address', function () {
        const amount = 100;
        const to = ZERO_ADDRESS;

        beforeEach(async function () {
          await this.token.approve(spender, amount, { from: owner });
        });

        it('reverts', async function () {
          await assertRevert(this.token.transferFrom(owner, to, amount, { from: spender }));
        });
      });
    });
});
