
pragma solidity 0.5.16;



interface IErc20Contract { // External ERC20 contract
    function transfer(address recipient, uint amount) external returns (bool);
    function balanceOf(address tokenOwner) external view returns (uint256);
}

contract DailyVesting {
    address public _admin;  // Admin address
    IErc20Contract public _erc20Contract;   // External ERC20 contract

    uint public _dateFrom;  // Start date
    uint public _dayToPay;  // How many days from dateFrom to dateTo

    mapping(address => uint) public _recipientAddressTotalAmount;   // Total amount of a recipient address
    mapping(address => uint) public _recipientAddressLeftAmount;    // Left amount of a recipient address
    mapping(address => uint) public _dailyAddressIndex;
    address[] public _recipientArr; // Recipient adreess in array

    bool public _hasAddressNotYetConfirmed = true; // Has address not yet confirmed? Default = true
    bool public _hasBalanceNotYetConfirmed = true; // Has balance not yet confirmed? Default = true

    constructor(
        uint dateFrom,
        uint dateTo,
        address erc20Contract
    ) public {
        require(dateTo >= dateFrom, 'Date to must be greater or equal to Date from');
        require(erc20Contract != address(0), "Zero address");
        _admin = msg.sender;
        _dateFrom = dateFrom;
        _dayToPay = (dateTo - dateFrom) / 86400 + 1;
        _erc20Contract = IErc20Contract(erc20Contract);
    }

    // Modifier
    modifier onlyAdmin() {
        require(_admin == msg.sender);
        _;
    }

    // Set the recipient addresses and amounts
    function setRecipientAddressesAmounts(address[] calldata recipientAddressArr, uint[] calldata amountArr) external onlyAdmin {
        require(_hasAddressNotYetConfirmed,
            'Unable to set recipient address amounts as all addresses have already been confirmed');
        require(recipientAddressArr.length == amountArr.length, 'The size of recipient address array must be same as amount array');
        for (uint i = 0; i < recipientAddressArr.length; i++) {
            require(recipientAddressArr[i] != address(0), "Zero address");
            require(amountArr[i] > 0, "Amount cannot be 0");
            require(!_isContract(recipientAddressArr[i]), 'Contracts are not allowed');
            _recipientAddressTotalAmount[recipientAddressArr[i]] = amountArr[i];
            _recipientAddressLeftAmount[recipientAddressArr[i]] = amountArr[i];
            _recipientArr.push(recipientAddressArr[i]);
        }
        _hasBalanceNotYetConfirmed = true;
    }

    // Confirm balance
    function confirmBalance() external onlyAdmin {
        require(_hasAddressNotYetConfirmed,
            'Unable to check balance as all addresses have already been confirmed');
        _hasBalanceNotYetConfirmed = false;
    }

    // Confirm the address and transfer ownership to this contract.
    // Once confirmed, no more address is allowed to be added
    function confirmAddressAndTransferOwnership() external onlyAdmin {
        require(!_hasBalanceNotYetConfirmed, 'Balance has not yet been confirmed');
        require(_hasAddressNotYetConfirmed, 'All addresses have already been confirmed');
        // Change the owernship to this contract
        _admin = address(this);
        _hasAddressNotYetConfirmed = false;
    }

    // Daily transfer
    function dailyTransfer() external {
        require(!_hasAddressNotYetConfirmed, "Unable to perform daily transfer as the address has not yet been confirmed");
        uint amountLeft = _recipientAddressLeftAmount[msg.sender];
        require (amountLeft > 0, "All amount was paid");
        uint dailyAmount = _recipientAddressTotalAmount[msg.sender] / _dayToPay;
        uint maxDayToPay = amountLeft / dailyAmount; // number of days that may be paid with dailyDistribution amount
        uint day = (block.timestamp - _dateFrom) / 86400 + 1;     // number of days to pay
        uint unpaidDays = day - _dailyAddressIndex[msg.sender];   // number of days to pay - already paid days
        if (unpaidDays > maxDayToPay + 1) unpaidDays = maxDayToPay + 1;
        uint amount = unpaidDays * dailyAmount;  // total amount to pay for passed days
        if (amount > 0) {
            bool canTransfer = _transfer(msg.sender, amount);
            if(canTransfer) {
                _dailyAddressIndex[msg.sender] = day;    // store last paid day
            }
        }
    }

    function _transfer(address recipient, uint amount) private returns (bool){
        // There is no validation on input parameters as this is a private function
        _recipientAddressLeftAmount[recipient] = _recipientAddressLeftAmount[recipient] - amount;
        return _erc20Contract.transfer(recipient, amount);
    }

    function _isContract(address addr) internal view returns (bool) { uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

}

