// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./TAO.sol";

contract Initiation {

    /*///////////////////////////////////////////////////////////////
                                EVENT
    //////////////////////////////////////////////////////////////*/

    event Initiated(address indexed to, initiation[] order);

    /*///////////////////////////////////////////////////////////////
                                INITIATION
    //////////////////////////////////////////////////////////////*/

    /// @notice TAO nft purchase
    struct initiation {
        TAO_NFT tao;
        uint amount;
    }

    /// @notice initiate into TAO's
    function initiate(initiation[] memory order) public payable {
        uint total;

        initiation memory _initiation;

        uint orderLength = order.length;

        for (uint i; i < orderLength; ) {
            _initiation = order[i];

            unchecked { total += _initiation.amount; }

            _initiation.tao.mint(msg.sender, _initiation.amount);

            unchecked { ++i; }
        }

        require(total == msg.value, "INCORRECT_VALUE");

        emit Initiated(msg.sender, order);
    }
}