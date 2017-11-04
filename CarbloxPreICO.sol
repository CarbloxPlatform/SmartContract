pragma solidity ^0.4.18;

import './CarbloxToken.sol';

// Carblox preICO contract

contract CarbloxPreICO is Ownable {

    using SafeMath for uint256;

    CarbloxToken token;

    uint256 public constant RATE = 7500;
    uint256 public constant START = 1509980400; // Mon, 06 Nov 2017 15:00
    uint256 public constant DAYS = 30;
  
    uint256 public constant initialTokens = 7801500 * 10**3;
    bool public initialized = false;
    uint256 public raisedAmount = 0;
    uint256 public participants = 0;

    event BoughtTokens(address indexed to, uint256 value);

    modifier whenSaleIsActive() {
        assert(isActive());
        _;
    }

    function CarbloxPreICO(address _tokenAddr) public {
        require(_tokenAddr != 0);
        token = CarbloxToken(_tokenAddr);
    }

    function initialize() public onlyOwner {
        require(initialized == false);
        require(tokensAvailable() == initialTokens);
        initialized = true;
    }

    function () public payable {
        require(msg.value >= 100000000000000000);
        buyTokens();
    }

    function buyTokens() public payable whenSaleIsActive {

        uint256 finneyAmount =  msg.value.div(1 finney);
        uint256 tokens = finneyAmount.mul(RATE);
        uint256 bonus = getBonus(tokens);
        
        tokens = tokens.add(bonus);

        BoughtTokens(msg.sender, tokens);
        raisedAmount = raisedAmount.add(msg.value);
        participants = participants.add(1);

        token.transfer(msg.sender, tokens);
        owner.transfer(msg.value);
    }

    function getBonus(uint256 _tokens) public constant returns (uint256) {

        require(_tokens > 0);
        
        if (START <= now && now < START + 5 days) {

            return _tokens.mul(30).div(100); // 30% days 1-5

        } else if (START + 5 days <= now && now < START + 10 days) {

            return _tokens.div(5); // 20% days 6-10

        } else if (START + 10 days <= now && now < START + 15 days) {

            return _tokens.mul(15).div(100); // 15% days 11-15

        } else if (START + 15 days <= now && now < START + 20 days) {

            return _tokens.div(10); // 10% days 16-20

        } else if (START + 20 days <= now && now < START + 25 days) {

            return _tokens.div(20); // 5% days 21-25

        } else {

            return 0;

        }
    }
    
    function isActive() public constant returns (bool) {
        return (
            initialized == true &&
            now >= START &&
            now <= START.add(DAYS * 1 days)
        );
    }

    function tokensAvailable() public constant returns (uint256) {
        return token.balanceOf(this);
    }

    function destroy() public onlyOwner {
        
        // Unsold tokens are burned
        
        uint256 balance = token.balanceOf(this);

        if (balance > 0) {
            token.burn(balance);
        }

        selfdestruct(owner);
    }
}
