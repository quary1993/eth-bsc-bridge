/*
 * A minimum multisig wallet interface. Compatible with MultiSigWallet by Gnosis.
 */
interface MultiSigWallet {
    function isOwner(address owner) external view returns (bool);
}

/**
 * @dev MultiOwnable contract.
 */
contract MultiOwnableContract {
    MultiSigWallet public wallet;

    event MultiOwnableWalletSet(
        address indexed _contract,
        address indexed _wallet
    );

    constructor(address _wallet) {
        wallet = MultiSigWallet(_wallet);
        emit MultiOwnableWalletSet(address(this), _wallet);
    }

    /** Check if a caller is the MultiSig wallet. */
    modifier onlyWallet() {
        require(address(wallet) == msg.sender);
        _;
    }

    /** Check if a caller is one of the current owners of the MultiSig wallet or the wallet itself. */
    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }

    function isOwner(address _address) public view returns (bool) {
        // NB due to lazy eval wallet could be a normal address and isOwner won't be called if the first condition is met
        return address(wallet) == _address || wallet.isOwner(_address);
    }

    /* PAUSABLE with upause callable only by wallet */

    bool public paused = false;

    event Pause();
    event Unpause();

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by any MSW owner to pause, triggers stopped state
     */
    function pause() public onlyWallet whenNotPaused {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the MSW (all owners) to unpause, returns to normal state
     */
    function unpause() public onlyWallet whenPaused {
        paused = false;
        emit Unpause();
    }
}
