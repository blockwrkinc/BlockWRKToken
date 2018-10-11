const { assertRevert } = require('openzeppelin-solidity/test/helpers/assertRevert');
const ERC865BasicTokenMock = artifacts.require('ERC865BasicTokenMock');

contract('ERC865BasicToken', function ([feeAccount, delegate]) {
    const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
    const owner = 0x1A5b8A59c528458A640D7018c1e806DFb96CbADa;
    const recipient = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;

    //Non-prefixed keccak256 value of args "0x14723a09acff6d2a60dcdf7aa4aff308fddc160c", 100, 2, 1
    const testMsg1 = 0x5ae9b77d7e583bdbe2718fbd2c2779a863d96da538527da8306b1e3850e8cc32;

    //Signature of testMsg1, signed by owner
    const testSig1 = 0xb60772b878067cb27811ed10b8dca85d1fa063b22f38808544f2ac877e0b5229085990b7ae77564c5b271514a0f872b2b84a570800841e084d6599fdfe9c8a2a1b;

    //Prefixed keccak256 of testMsg1 (see hashTesting.sol)
    const prefixedMsg1 = 0x70f6ef37c25c22c642ff45e318087960712199966987e73afa8490a754a57f9e;

    beforeEach(async function () {
        this.erc865BasicToken = await ERC865BasicTokenMock.new(owner, 1000, feeAccount);
    });

    describe('transfer presigned', function () {

    });
});
