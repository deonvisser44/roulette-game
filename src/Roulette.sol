// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Roulette {
    address public admin;
    uint256 public houseBalance;
    mapping(address => uint256) public playerBalances;

    event FundsDeposited(address indexed admin, uint256 amount);
    event PlayerDeposited(address indexed player, uint256 amount);
    event PlayerWithdrew(address indexed player, uint256 amount);
    event GamePlayed(
        address indexed player,
        uint256 betAmount,
        uint256 outcome,
        bool won,
        uint256 winnings
    );
    event ColorBetPlayed(
        address indexed player,
        uint256 betAmount,
        uint256 outcome,
        bool won,
        string color,
        uint256 winnings
    );

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action.");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function depositFunds() external payable onlyAdmin {
        require(msg.value > 0, "Must deposit a positive amount.");
        houseBalance += msg.value;
        emit FundsDeposited(msg.sender, msg.value);
    }

    function playerDeposit() external payable {
        require(msg.value > 0, "Must deposit a positive amount.");
        playerBalances[msg.sender] += msg.value;
        emit PlayerDeposited(msg.sender, msg.value);
    }

    function playerWithdraw(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be positive.");
        require(playerBalances[msg.sender] >= amount, "Insufficient balance.");

        playerBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit PlayerWithdrew(msg.sender, amount);
    }

    function playGame(uint256 betAmount, uint8 betOn) external {
        require(betAmount > 0, "Bet amount must be positive.");
        require(
            playerBalances[msg.sender] >= betAmount,
            "Insufficient balance to place the bet."
        );
        require(
            betOn >= 0 && betOn <= 36,
            "Invalid bet number. Choose between 0 and 36."
        );

        playerBalances[msg.sender] -= betAmount;
        uint256 outcome = random() % 37; // Roulette has numbers 0 to 36
        bool won = (outcome == betOn);
        uint256 winnings = 0;

        if (won) {
            winnings = betAmount * 35; // Standard roulette payout for a single number
            require(
                houseBalance >= winnings,
                "House does not have enough funds to pay out."
            );
            houseBalance -= winnings;
            playerBalances[msg.sender] += betAmount + winnings;
        } else {
            houseBalance += betAmount;
        }

        emit GamePlayed(msg.sender, betAmount, outcome, won, winnings);
    }

    function playColorBet(uint256 betAmount, string memory color) external {
        require(betAmount > 0, "Bet amount must be positive.");
        require(
            playerBalances[msg.sender] >= betAmount,
            "Insufficient balance to place the bet."
        );
        require(
            keccak256(abi.encodePacked(color)) ==
                keccak256(abi.encodePacked("red")) ||
                keccak256(abi.encodePacked(color)) ==
                keccak256(abi.encodePacked("black")),
            "Invalid color. Choose 'red' or 'black'."
        );

        playerBalances[msg.sender] -= betAmount;
        uint256 outcome = random() % 37; // Roulette has numbers 0 to 36

        // Numbers considered red and black on a standard roulette wheel
        bool isRed = (outcome == 1 ||
            outcome == 3 ||
            outcome == 5 ||
            outcome == 7 ||
            outcome == 9 ||
            outcome == 12 ||
            outcome == 14 ||
            outcome == 16 ||
            outcome == 18 ||
            outcome == 19 ||
            outcome == 21 ||
            outcome == 23 ||
            outcome == 25 ||
            outcome == 27 ||
            outcome == 30 ||
            outcome == 32 ||
            outcome == 34 ||
            outcome == 36);

        bool won = (isRed &&
            keccak256(abi.encodePacked(color)) ==
            keccak256(abi.encodePacked("red"))) ||
            (!isRed &&
                keccak256(abi.encodePacked(color)) ==
                keccak256(abi.encodePacked("black")));

        uint256 winnings = 0;
        if (won) {
            winnings = betAmount * 2; // Standard payout for color bets
            require(
                houseBalance >= winnings,
                "House does not have enough funds to pay out."
            );
            houseBalance -= winnings;
            playerBalances[msg.sender] += betAmount + winnings;
        } else {
            houseBalance += betAmount;
        }

        emit ColorBetPlayed(
            msg.sender,
            betAmount,
            outcome,
            won,
            color,
            winnings
        );
    }

    function random() internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.prevrandao,
                        msg.sender
                    )
                )
            );
    }
}
