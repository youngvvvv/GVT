// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/access/Ownable.sol";

contract GovernanceToken is ERC721, Ownable {
    uint256 public tokenCounter;
    uint256 public totalVotesFor;
    uint256 public totalVotesAgainst;

    // 각 NFT가 가진 투표 영향력 저장
    mapping(uint256 => uint256) public votingPower;
    mapping(uint256 => bool) public votedTokens; // 각 토큰의 투표 여부 기록

    constructor() ERC721("GovernanceVotingToken", "GVT") {
        tokenCounter = 0;
    }

    // 새로운 NFT를 발행하고 투표 영향력을 부여하는 함수
    function mintWithVotingPower(address recipient, uint256 power) public onlyOwner {
        _safeMint(recipient, tokenCounter);
        votingPower[tokenCounter] = power; // 토큰에 투표 영향력 부여
        tokenCounter++;
    }

    // 여러 명에게 각기 다른 투표 영향력을 가진 NFT를 배포하는 함수
    function mintMultipleToRecipients(address[] memory recipients, uint256[] memory powers) public onlyOwner {
        require(recipients.length == powers.length, "Recipients and powers must have the same length");

        for (uint256 i = 0; i < recipients.length; i++) {
            _safeMint(recipients[i], tokenCounter); // 각 수신자에게 NFT 발행
            votingPower[tokenCounter] = powers[i]; // 각 NFT에 투표 영향력 부여
            tokenCounter++;
        }
    }

    // 특정 토큰이 가진 투표 권한을 확인하는 함수
    function getVotingPower(uint256 tokenId) public view returns (uint256) {
        return votingPower[tokenId];
    }

    // 거버넌스 투표를 위한 함수 (특정 토큰을 이용해 투표)
    function vote(uint256 tokenId, bool voteFor) public {
        require(ownerOf(tokenId) == msg.sender, "You must own the token to vote.");
        require(!votedTokens[tokenId], "Token has already been used to vote.");

        uint256 power = votingPower[tokenId]; // 투표 영향력 가져오기

        if (voteFor) {
            totalVotesFor += power;  // 찬성 투표 영향력을 반영
        } else {
            totalVotesAgainst += power;  // 반대 투표 영향력을 반영
        }

        votedTokens[tokenId] = true; // 해당 토큰을 사용해 투표 완료로 표시
    }

     // 투표 결과 비율을 비교하고 결과를 보여주는 함수
    function getVotingResult() public view returns (string memory) {
        if (totalVotesFor == 0 && totalVotesAgainst == 0) {
            return "No votes have been cast.";
        } else if (totalVotesFor > totalVotesAgainst) {
            return "More votes for the proposal.";
        } else if (totalVotesFor < totalVotesAgainst) {
            return "More votes against the proposal.";
        } else {
            return "The votes are tied.";
        }
    }
}
