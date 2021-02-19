//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.8.0;

import "./ERC20Detailed.sol";
import "./Ownable.sol";

contract mirrorERC20 is ERC20Detailed, Ownable {
    address public BEP20Address;

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint8 decimals,
        address _BEP20Address
    ) ERC20Detailed(_tokenName, _tokenSymbol, decimals) {
        BEP20Address = _BEP20Address;
    }

    function burnSupply(uint256 amount, address requestOwner)
        external
        onlyOwner
    {
        _burn(requestOwner, amount);
    }

    function mintSupply(uint256 amount, address requestOwner)
        external
        onlyOwner
    {
        _mint(requestOwner, amount);
    }
}
