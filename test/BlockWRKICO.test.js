const { assertRevert } = require('openzeppelin-solidity/test/helpers/assertRevert');
const { advanceBlock } = require('openzeppelin-solidity/test/helpers/advanceToBlock');
const { ether } = require('openzeppelin-solidity/test/helpers/ether');
const { expectThrow } = require('openzeppelin-solidity/test/helpers/expectThrow');
const { EVMRevert } = require('openzeppelin-solidity/test/helpers/EVMRevert');
const { ethGetBalance } = require('openzeppelin-solidity/test/helpers/web3');
const { increaseTimeTo, duration } = require('openzeppelin-solidity/test/helpers/increaseTime');
const { latestTime } = require('openzeppelin-solidity/test/helpers/latestTime');
const BlockWRKICOMock = artifacts.require('BlockWRKICOMock');

contract('BlockWRKICO', function ([_, _purchaser, _salesWallet, _poolWallet]) {
    const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

    //Variables for constructor
    const purchaser = _purchaser;
    const cap = ether(3);
    const weiRaised = ether(1);
    const salesWallet = _salesWallet;
    const poolWallet = _poolWallet;

    //Contract access
    let owner;

    before(async function () {
        //Advance to the next block to correctly read time in the solidity "now" function interpreted by ganache
        await advanceBlock();
    });

    beforeEach(async function () {
        //Setup ICO sale times
        this.openingTime = (await latestTime()) + duration.weeks(1);
        this.closingTime = this.openingTime + duration.weeks(1);
        this.afterClosingTime = this.closingTime + duration.seconds(1);

        this.ico = await BlockWRKICOMock.new(cap, weiRaised, salesWallet, poolWallet, this.openingTime, this.closingTime);
    });

    beforeEach(async function () {
        //Get contract owner
        owner = await this.ico.owner();
    });

    describe('as a timed crowdsale', function() {
        it('should be ended only after end', async function () {
            let ended = await this.ico.hasClosed();
            ended.should.equal(false);
            await increaseTimeTo(this.afterClosingTime);
            ended = await this.ico.hasClosed();
            ended.should.equal(true);
        });
    });

    describe('as a capped crowdsale', function () {
        it('should reach cap if cap sent', async function () {
            //Sale is open
            await increaseTimeTo(this.openingTime);

            //Purchase tokens (note 1 already raised, cap is 3)
            await this.ico.buyTokens(purchaser, { value: ether(2), from: purchaser });
            const capReached = await this.ico.capReached();
            capReached.should.equal(true);
        });
    });

    describe('buy tokens', function () {
        describe('when the beneficiary is not the zero address', function () {
            describe('when the wei amount is not zero', function () {
                describe('when the total wei raised is less than the hardcap', function () {
                    describe('when the crowdsale is open', async function () {
                        it('issues tokens', async function () {
                            //Sale is open
                            await increaseTimeTo(this.openingTime);
                            const before = await this.ico.totalSupply();

                            //Purchase tokens
                            await this.ico.buyTokens(purchaser, { value: ether(1), from: purchaser });

                            //Validate
                            const purchaserBalance = await this.ico.balanceOf(purchaser);
                            const after = await this.ico.totalSupply();
                            assert.equal(purchaserBalance, 2000000000);
                            assert.equal((after - before), 2000000000);
                        });

                        it('transfers fundsto the salesWallet', async function () {
                            //Sale is open
                            await increaseTimeTo(this.openingTime);
                            const pre = await ethGetBalance(salesWallet);

                            //Purchase tokens
                            await this.ico.buyTokens(purchaser, { value: ether(1), from: purchaser });

                            //Validate
                            const post = await ethGetBalance(salesWallet);
                            assert.equal((post - pre), ether(1));
                        });

                        it('emits the purchase event', async function() {
                            //Sale is open
                            await increaseTimeTo(this.openingTime);

                            //Purchase tokens
                            const { logs } = await this.ico.buyTokens(purchaser, { value: ether(1), from: purchaser });

                            //Validate
                            assert.equal(logs.length, 1);
                            assert.equal(logs[0].event, 'TokenPurchase');
                            assert.equal(logs[0].args.purchaser, purchaser);
                            assert.equal(logs[0].args.beneficiary, purchaser);
                            assert.equal(logs[0].args.value, 1000000000000000000);
                            assert.equal(logs[0].args.amount, 2000000000);
                        });
                    });
                });

                describe('when the amount sent plus the wei raised is more than the hardcap', function () {
                    it('reverts', async function () {
                        //Sale is open
                        await increaseTimeTo(this.openingTime);

                        //Purchase tokens (note 1 already raised and cap is 3)
                        await assertRevert(this.ico.buyTokens(purchaser, { value: ether(3), from: purchaser }));
                    });
                });
            });

            describe('when the wei amount is zero', function () {
                it('reverts', async function () {
                    //Sale is open
                    await increaseTimeTo(this.openingTime);

                    //Purchase tokens
                    await assertRevert(this.ico.buyTokens(purchaser, { value: 0, from: purchaser }));
                });
            });
        });

        describe('when the beneficiary is the zero address', function () {
            it('reverts', async function () {
                //Sale is open
                await increaseTimeTo(this.openingTime);

                //Purchase tokens
                await assertRevert(this.ico.buyTokens(ZERO_ADDRESS, { value: ether(1), from: purchaser }));
            });
        });
    });

    describe('transfer remaining tokens after the sale', function() {
        describe('when the sender is the owner', function () {
            describe('when the crowdsale has ended', function () {
                describe('when available tokens is greater than zero', function() {
                    it('transfers the remaining tokens to the distribution pool wallet', async function () {
                        //Sale Closed
                        await increaseTimeTo(this.afterClosingTime);

                        const premine = await this.ico.balanceOf(poolWallet);

                        //Closeout sale
                        await this.ico.transferRemainingTokens({ from: owner });

                        //validate
                        const postSale = await this.ico.balanceOf(poolWallet);
                        assert.equal((postSale - premine), 4000000000);
                    });

                    it('emits the closeout sale event', async function () {
                        //Sale Closed
                        await increaseTimeTo(this.afterClosingTime);

                        //Closeout sale
                        const { logs } = await this.ico.transferRemainingTokens({ from: owner });

                        //Validate
                        assert.equal(logs.length, 1);
                        assert.equal(logs[0].event, 'CloseoutSale');
                        assert.equal(logs[0].args.wallet, poolWallet);
                        assert.equal(logs[0].args.amount, 4000000000);
                    });
                });

                describe('when available tokens is not greater than zero', function () {
                    it('reverts', async function () {
                        //Sale is open
                        await increaseTimeTo(this.openingTime);

                        //Exhaust remaining token supply (note availableInSale)
                        await this.ico.buyTokens(purchaser, { value: ether(2), from: purchaser });

                        //Sale Closed
                        await increaseTimeTo(this.afterClosingTime);

                        //Owner attempts to call function
                        await assertRevert(this.ico.transferRemainingTokens({ from: owner }));
                    });
                });
            });

            describe('when the crowdsale has not ended', async function () {
                it('reverts', async function() {
                    //Sale is open
                    await increaseTimeTo(this.openingTime);

                    //Call function
                    await assertRevert(this.ico.transferRemainingTokens({ from: owner }));
                });
            });
        });

        describe('when the sender is not the owner', function() {
            it('reverts', async function () {
                await assertRevert(this.ico.transferRemainingTokens({ from: purchaser }));
            });
        });
    });
});
