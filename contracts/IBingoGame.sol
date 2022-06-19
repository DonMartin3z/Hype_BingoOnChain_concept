// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IBingoGame {
    event NumberDrawn(uint8 number);
    event GameWon(
        uint256 timestamp,
        address indexed winner,
        uint256 awardAmount
    );

    function init(
        uint256 gameUUID,
        uint256 drawTimeIntervalSec,
        address[] calldata players
    ) external;

    function drawNumber() external;

    function claimBingo(uint256 tokenId) external returns (bool isBingo);

    function getDrawnNumbers() external view returns (uint8[] memory);
}
