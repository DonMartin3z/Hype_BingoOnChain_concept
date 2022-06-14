// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";

import "contracts/IBingo.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// uint8 constant B_MIN_VALUE = 1;
// uint8 constant B_MAX_VALUE = 15;
// uint8 constant I_MIN_VALUE = 16;
// uint8 constant I_MAX_VALUE = 30;
// uint8 constant N_MIN_VALUE = 31;
// uint8 constant N_MAX_VALUE = 45;
// uint8 constant G_MIN_VALUE = 46;
// uint8 constant G_MAX_VALUE = 60;
// uint8 constant O_MIN_VALUE = 61;
// uint8 constant O_MAX_VALUE = 75;

contract Bingo is IBingo, Ownable {
    // Long-term: move this to NFT generation. For now, a double mapping works
    struct BoardElement {
        uint8 value;
        bool  hasBeenDrawn;
    }

    struct BoardGeneration {
        bool                   isInitialized;
        mapping(uint8 => bool) hasNumBeenUsed;
    }

    struct PlayerBoard {
        BoardGeneration gen;
        BoardElement[5] bColumn;
        BoardElement[5] iColumn;
        BoardElement[5] nColumn;    // element 2 is the "free" element
        BoardElement[5] gColumn;
        BoardElement[5] oColumn;
    }

    mapping(address => PlayerBoard) private playerGameBoards;
    uint8[] public drawnNumbers;

    // What are the large operations I must do?
    // 1. Generate the board according to bingo rules (number ranges for each column)
    // 2. On claimBingo, efficiently check the player board for the win condition

    // Per the Standard US Bingo Rules
    uint8 constant B_OFFSET = 0 * 15;
    uint8 constant I_OFFSET = 1 * 15;
    uint8 constant N_OFFSET = 2 * 15;
    uint8 constant G_OFFSET = 3 * 15;
    uint8 constant O_OFFSET = 4 * 15;

    uint constant public WEI_BUY_IN = 10 wei;

    modifier onlyPlayers() {
        require(
            playerGameBoards[msg.sender].gen.isInitialized, "Player must have a board to call this function");
        _;
    }

    // CREATE A RANDOM NUMBER - GENERATE FUNCTION
    // -------------------------------------------------------------
    // Generate a random number (Can be replaced by Chainlink)
    function rng(uint _input) private view returns(uint256){
        console.log("rng()");
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
            block.number + (_input * 1 minutes)
        )));
        uint number = (seed - ((seed / 100) * 100));
        return number;
    }

    // RANDOMLY GENERATE A SINGLE COLUMN OF THE PLAYER BOARD
    // -------------------------------------------------------------
    function generateColumn(
        PlayerBoard storage self,
        BoardElement[5] storage column,
        uint8 columnOffset)
        private
    {
        console.log("generateColumn()");

        uint8 randomNum;
        for(uint i = 0; i < column.length;) {
            // Mod 15 results in a uint in the range [0, 14], so add 1 to get to range [1, 15]
            // Then, multiply by the offset for the desired column
            randomNum = uint8(((rng(i+1) % 15) + 1)) * columnOffset;

            // Only increment when we find a non-colliding random number for the current column
            if(!self.gen.hasNumBeenUsed[randomNum]) {
                console.log("numGenerated");
                console.log(randomNum);

                column[i].value = randomNum;
                self.gen.hasNumBeenUsed[randomNum] = true;
                i++;
            }
        }
    }

    // RANDOMLY GENERATE THE PLAYER BOARD
    // -------------------------------------------------------------
    function generateBoard(PlayerBoard storage self) private {
        console.log("generateBoard()");

        generateColumn(self, self.bColumn, B_OFFSET);
        generateColumn(self, self.iColumn, I_OFFSET);
        generateColumn(self, self.nColumn, N_OFFSET);
        generateColumn(self, self.gColumn, G_OFFSET);
        generateColumn(self, self.oColumn, O_OFFSET);

        self.gen.isInitialized = true;
    }

    function joinGame() external payable {
        console.log("joinGame()");

        // require(msg.value >= WEI_BUY_IN, "Player has not met minimum buy in");
        require(!playerGameBoards[msg.sender].gen.isInitialized, "Player has already joined the game");

        generateBoard(playerGameBoards[msg.sender]);

        emit GameJoined(msg.sender);
    }

    function startGame() external onlyOwner {
        console.log("startGame()");
        emit GameStarted(block.timestamp);
    }

    function getBoard() external onlyPlayers returns(string memory boardStr) {
        console.log("getBoard()");
        return "this is a board";
    }

    function drawNumber() external onlyOwner {
        console.log("drawNumber()");
        emit NumberDrawn(0);
    }

    function claimBingo() external onlyPlayers {
        console.log("claimBingo()");
    }

}