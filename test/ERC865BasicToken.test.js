const { assertRevert } = require('openzeppelin-solidity/test/helpers/assertRevert');
const ERC865BasicTokenMock = artifacts.require('ERC865BasicTokenMock');

contract('ERC865BasicToken', function ([j, k, feeAccount, delegate]) {
    const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
    const _delegate = delegate;

    //Owner account to use for verifying signed message
    const owner = '0x1a5b8a59c528458a640d7018c1e806dfb96cbada';

    //Non-prefixed keccak256 value of args "0x14723a09acff6d2a60dcdf7aa4aff308fddc160c", 100, 2, 1
    const testMsg1 = '0x5ae9b77d7e583bdbe2718fbd2c2779a863d96da538527da8306b1e3850e8cc32';

    //Signature of testMsg1, signed by owner
    const testSig1 =
        '0xb60772b878067cb27811ed10b8dca85d1fa063b22f38808544f2ac877e0b5229085990b7ae77564c5b271514a0f872b2b84a570800841e084d6599fdfe9c8a2a1b';

    //Transaction 1 arguments
    const to = '0x14723a09acff6d2a60dcdf7aa4aff308fddc160c';
    const amount = 100;
    const fee = 2;
    const nonce = 1;

    //Signature of testMsg2, signed by owner
    const testSig2 =
        '0x6624761bd0af353cf60bb6b8b71aa7333dc3e84d9685afc2aae0dbc873af2b2a6ab1a6b9d4674d1da15f67eb47140702cac93ec2c4fc395fdd183260676a65d11c';

    //Non-prefixed keccak256 value of args "0x14723a09acff6d2a60dcdf7aa4aff308fddc160c", 1000, 2, 3
    const testMsg3 = '0xba8d5962e0104473dd6a49779d2afa5102c737ee651e58dc159c01d3cc38b5ea';

    //Signature of testMsg3, signed by owner
    const testSig3 =
        '0x4e3394caf6d11fac2dbeaf844529a3a386f19ffd1a248372d515c9a0958d26ed04f470da231b51625fc6cd82dfdc3690b53ac47280220202632011aaeee844f51c';

    beforeEach(async function () {
        this.token = await ERC865BasicTokenMock.new(owner, 1000, feeAccount, testSig2);
    });

    describe('transfer presigned', function () {
        describe('when the recipient is not the zero address', function () {
            describe('when the signature is original', function () {
                describe('when the from address is recovered', function () {
                    describe('when the owner has enough balance', async function () {
                        it('transfers the requested amount', async function () {
                            await this.token.
                                _transferPreSigned(testSig1, owner, to, amount, fee, nonce, { from: _delegate });

                            const senderBalance = await this.token.balanceOf(owner);
                            assert.equal(senderBalance, 898);
                            const recipientBalance = await this.token.balanceOf(to);
                            assert.equal(recipientBalance, 100);
                            const feeAccountBalance = await this.token.balanceOf(feeAccount);
                            assert.equal(feeAccountBalance, 2);
                        });

                        it('emits the transfer events', async function () {
                            const { logs } = await this.token.
                                _transferPreSigned(testSig1, owner, to, amount, fee, nonce, { from: _delegate });

                            assert.equal(logs.length, 2);
                            assert.equal(logs[0].event, 'TransferPreSigned');
                            assert.equal(logs[0].args.delegate, _delegate);
                            assert.equal(logs[0].args.from, owner);
                            assert.equal(logs[0].args.to, to);
                            assert(logs[0].args.value.eq(100));
                            assert.equal(logs[1].event, 'TransferPreSigned');
                            assert.equal(logs[1].args.delegate, _delegate);
                            assert.equal(logs[1].args.from, owner);
                            assert.equal(logs[1].args.to, feeAccount);
                            assert(logs[1].args.value.eq(2));
                        });
                    });
                    describe('when the owner does not have enough balance', async function () {
                        it('reverts', async function () {
                            await assertRevert(this.token.
                                _transferPreSigned(testSig3, owner, to, 1000, 2, 3, { from: _delegate }));
                        });
                    });
                });

                describe('when the from address is not recovered', async function () {
                    const wrong = to;

                    it('reverts', async function () {
                        await assertRevert(this.token.
                            _transferPreSigned(testSig1, wrong, to, amount, fee, nonce, { from: delegate }));
                    });
                });
            });

            describe('when the signature is not original', async function () {
                it('reverts', async function () {
                    await assertRevert(this.token.
                        _transferPreSigned(testSig2, owner, to, 10, 2, 2, {from: delegate }));
                });
            });
        });

        describe('when the recipient is the zero address', async function () {
            const zero = ZERO_ADDRESS;

            it('reverts', async function () {
                await assertRevert(this.token.
                    _transferPreSigned(testSig1, owner, zero, amount, fee, nonce, { from: delegate }));
            });
        });
    });
});
