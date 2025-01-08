// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

contract Token {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private constant _decimals = 18;

    uint256 public constant presaleReserve = 60_000_000_000 * (10 ** _decimals);
    uint256 public constant stakingReserve = 24_000_000_000 * (10 ** _decimals);
    uint256 public constant marketingReserve = 56_000_000_000 * (10 ** _decimals);
    uint256 public constant liquidityReserve = 30_000_000_000 * (10 ** _decimals);
    uint256 public constant DEXRewardsReserve = 30_000_000_000 * (10 ** _decimals);
    bool public firstBuyCompleted = false;
    address public uniswapPool;
    address private _owner;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event FirstBuyDone();

    modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not the owner");
        _;
    }

    constructor() {
        _name = "Vaultinu";
        _symbol = "VINU";
        _owner = msg.sender;
        _mint(0x859b33e7AC7Ca00f47F36f2106adb1E5569C009F, presaleReserve);
        _mint(0x1Ed636F46cEda0229e62f9639ce23D672C77D1f8, stakingReserve);
        _mint(0xf9ca918472E6ef0ACEf7509275E0D59F1e37ABE6, marketingReserve);
        _mint(0xC4aD30031077253590b97EcEcb5925E0f08B79ca, liquidityReserve);
        _mint(0x30B63892Ea7Ae3519f23D5860544bF03cb8EA0d2, DEXRewardsReserve);
    }


    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "Decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);

        return true;
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function setUniswapPool(address _uniswapPool) external onlyOwner {
        require(_uniswapPool != address(0), "Uniswap pool address cannot be zero");
        uniswapPool = _uniswapPool;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(_balances[sender] >= amount, "Transfer amount exceeds balance");

        if (!firstBuyCompleted && sender == uniswapPool) {
            require(tx.origin == _owner, "First Buy Pending");
            firstBuyCompleted = true;
            emit FirstBuyDone();
        }

        _balances[sender] -= amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "Mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;

        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "Burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "Burn amount exceeds balance");

        _balances[account] -= amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

