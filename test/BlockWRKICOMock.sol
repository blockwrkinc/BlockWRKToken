pragma solidity ^0.4.24;

import "./../contracts/BlockWRKICO.sol";

contract BlockWRKICOMock is BlockWRKICO {
    constructor(
        uint256 _cap,
        uint256 _weiRaised,
        address _salesWallet,
        address _distributionPoolWallet,
        uint256 _openingTime,
        uint256 _closingTime
    )
        public
    {
        cap = _cap;
        weiRaised = _weiRaised;
        salesWallet = _salesWallet;
        distributionPoolWallet = _distributionPoolWallet;
        reservedTokenWallet = owner;
        openingTime = _openingTime;
        closingTime = _closingTime;

        totalPremineVolume = 76000000000000;
        totalSaleVolume = 4000000000;
        totalTokenVolume = 119000000000000;
        availableInSale = totalSaleVolume;
        tier1Rate = 200000;
        tier2Rate = 40000;
        tier3Rate = 20000;
        tier4Rate = 10000;
        tier5Rate = 10000;
        tier6Rate = 10000;
        tier7Rate = 10000;
        tier8Rate = 10000;
        tier9Rate = 10000;
        tier10Rate = 10000;
        tier1Volume = totalPremineVolume.add(1000000000000);
        tier2Volume = tier1Volume.add(2000000000000);
        tier3Volume = tier2Volume.add(5000000000000);
        tier4Volume = tier3Volume.add(5000000000000);
        tier5Volume = tier4Volume.add(5000000000000);
        tier6Volume = tier5Volume.add(5000000000000);
        tier7Volume = tier6Volume.add(5000000000000);
        tier8Volume = tier7Volume.add(5000000000000);
        tier9Volume = tier8Volume.add(5000000000000);
        tier10Volume = tier9Volume.add(5000000000000);

        premineDistributionPool = decimalValue.mul(5600000000);
        premineReserved = decimalValue.mul(2000000000);
        INITIAL_SUPPLY = premineDistributionPool.add(premineReserved);
        balances[distributionPoolWallet] = premineDistributionPool;
        balances[reservedTokenWallet] = premineReserved;
        totalSupply_ = INITIAL_SUPPLY;
    }
}
