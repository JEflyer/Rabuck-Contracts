//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


library minterLib {

    
    event PriceIncrease(uint256 newPrice);


    function getPrice(uint8 amount, uint256 price, uint16 currentMintedAmount) internal pure returns (uint256 givenPrice){
        bool answer = crossesThreshold(amount,currentMintedAmount);
        if(answer){
            (uint8 amountBefore, uint8 amountAfter) = getAmounts(amount,currentMintedAmount);
            givenPrice = (price*amountBefore) + (price * 2 * amountAfter);
        } else {
            givenPrice = price * amount;
        }
    }


    function updatePrice(uint _price)internal returns(uint price) {
        price = _price + (_price*2/100);
        emit PriceIncrease(price);
    }

    //checks if the amount crosses a multiple of 1000 & returns a bool
    function crossesThreshold(uint _amount, uint _totalSupply) internal pure returns (bool){
        if(_totalSupply+_amount < 100) return false;
        uint remainder = (_totalSupply + _amount) % 100;
        if(remainder >= 0 && remainder < 10) {
            return true;
        } else {
            return false;
        }
    }

    //get amounts on each side of the 1k split
    //for example: amount 5, totalSupply 998
    //amountBefore 2, amountAfter 3
    function getAmounts(uint _amount, uint _totalSupply) internal pure returns(uint8 amountBefore, uint8 amountAfter){
        for (uint i = 0; i < _amount; i++){
            if (crossesThreshold(i+1,_totalSupply)){
                amountBefore = uint8(i +1);
                amountAfter = uint8(_amount-amountBefore);
                break;
            }
        }
    }

    function getDiv(uint16[] memory _shares) internal pure returns(uint16 divider){
        divider = 0;
        for(uint j = 0; j<_shares.length; j++){
            divider += _shares[j];
        }
    }
}