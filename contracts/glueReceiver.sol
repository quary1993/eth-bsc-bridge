//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.8.0;

import "./SafeMath.sol";
import "./MultiOwnableContract.sol";
import "./mirrorERC20.sol";

contract GlueReceiver is MultiOwnableContract {
    using SafeMath for uint256;

    struct BEP20TokenData {
        address ERC20Address;
        address BEP20Address;
        string name;
        string symbol;
        uint8 decimals;
        uint256 totalSupply;
        uint256 BEP20Supply;
    }

    struct BEP20MintRequest {
        address tokenAddress;
        address requestOwner;
        uint256 amount;
        bool isResolved;
    }

    struct BEP20UnlockRequest {
        address tokenAddress;
        address requestOwner;
        uint256 amount;
        bool isResolved;
    }

    struct mirrorToken {
        address BEP20Address;
        address ERC20Address;
        bool deployed;
    }

    uint256 public BEP20_DEPLOY_FEE;

    uint256 public BEP20_MINT_FEE;

    uint256 public BEP20TokenRequestsLength;

    uint256 public BEP20MintRequestsLength;

    uint256 public BEP20UnlockRequestsLength;

    mapping(uint256 => address) public BEP20TokenRequests;

    mapping(address => BEP20TokenData) public BEP20Token;

    mapping(uint256 => BEP20MintRequest) public BEP20MintRequests;

    mapping(address => mirrorToken) public mirroredBEP20;

    mapping(uint256 => BEP20UnlockRequest) public BEP20UnlockRequests;

    constructor(
        uint256 _deploy_fee,
        uint256 _mint_fee,
        address addr
    ) MultiOwnableContract(addr) {
        BEP20TokenRequestsLength = 0;
        BEP20MintRequestsLength = 0;
        BEP20UnlockRequestsLength = 0;
        BEP20_DEPLOY_FEE = _deploy_fee;
        BEP20_MINT_FEE = _mint_fee;
    }

    function glueBEP20(address tokenAddress) external payable {
        IERC20 token = IERC20(tokenAddress);

        require(msg.value >= BEP20_DEPLOY_FEE, "Insufficient deploy fee");
        require(
            BEP20Token[tokenAddress].totalSupply == 0,
            "Token contract already glued"
        );

        BEP20TokenData memory deployedToken;

        deployedToken.ERC20Address = tokenAddress;
        deployedToken.symbol = token.name();
        deployedToken.symbol = token.symbol();
        deployedToken.decimals = token.decimals();
        deployedToken.totalSupply = token.totalSupply();

        //declare and map the new BEP20Token
        BEP20Token[tokenAddress] = deployedToken;
        //Create a pending BEP20 deployment request
        BEP20TokenRequests[BEP20TokenRequestsLength] = tokenAddress;
        //Increase the requests counter
        BEP20TokenRequestsLength++;
    }

    function deployMirrorERC20(
        address BEP20Address,
        string memory __name,
        string memory __symbol,
        uint8 __decimals
    ) external onlyOwner {
        mirrorERC20 mirrorTokenContract =
            new mirrorERC20(__name, __symbol, __decimals, BEP20Address);
        mirrorToken memory mirrorERC20Token;
        mirrorERC20Token.ERC20Address = address(mirrorTokenContract);
        mirrorERC20Token.BEP20Address = BEP20Address;
        mirrorERC20Token.deployed = true;
        mirroredBEP20[address(mirrorTokenContract)] = mirrorERC20Token;
    }

    function increaseBEP20Supply(address tokenAddress, uint256 amount)
        external
        payable
    {
        IERC20 token = IERC20(tokenAddress);

        token.transferFrom(msg.sender, address(this), amount); // send the tokens to this contract

        require(msg.value > BEP20_MINT_FEE, "Insufficient Mint Fee");

        BEP20MintRequest memory request;
        request.tokenAddress = tokenAddress;
        request.amount = amount;
        request.requestOwner = msg.sender;
        BEP20MintRequests[BEP20TokenRequestsLength] = request;
        BEP20TokenRequestsLength++; // create the mint request for Bep20 and increase the requests length

        BEP20Token[tokenAddress].BEP20Supply = BEP20Token[tokenAddress]
            .BEP20Supply
            .add(amount);
    }

    function decreaseBEP20Supply(
        address tokenAddress,
        uint256 amount,
        address receiver
    ) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);

        BEP20Token[tokenAddress].BEP20Supply = BEP20Token[tokenAddress]
            .BEP20Supply
            .sub(amount);
        token.transfer(receiver, amount);
    }

    function requestUnlock(uint256 amount, address mirrorTokenAddress)
        external
    {
        require(
            mirroredBEP20[mirrorTokenAddress].deployed == true,
            "Specified token not deployed"
        );
        mirrorERC20(mirrorTokenAddress).burnSupply(amount, msg.sender);
        BEP20UnlockRequest memory request;
        request.tokenAddress = mirrorTokenAddress;
        request.requestOwner = msg.sender;
        request.amount = amount;

        BEP20UnlockRequests[BEP20UnlockRequestsLength] = request;
        BEP20UnlockRequestsLength++;
    }

    function setBEP20DeployFee(uint256 fee) external onlyOwner {
        BEP20_DEPLOY_FEE = fee;
    }

    function setBEP20MintFee(uint256 fee) external onlyOwner {
        BEP20_MINT_FEE = fee;
    }

    function withdrawFees(uint256 amount, address payable to)
        external
        onlyOwner
    {
        to.transfer(amount);
    }
}
