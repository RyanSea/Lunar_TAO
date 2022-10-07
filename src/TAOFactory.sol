// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./TAO.sol";

contract TAOFactory {

    /*///////////////////////////////////////////////////////////////
                            INITIALIZATION
    ///////////////////////////////////////////////////////////////*/

    /// @notice initiaton contract address
    address immutable initiator; 

    constructor(address _initiator) {
        initator = _initiator;
    }

    /// @notice guild => TAO[] they've deployed
    mapping(address => TAO[]) public guildDeployed;

    /*///////////////////////////////////////////////////////////////
                                EVENTS
    ///////////////////////////////////////////////////////////////*/

    event TAOCreated(address indexed guild, address indexed tao);

    /*///////////////////////////////////////////////////////////////
                                CREATION
    ///////////////////////////////////////////////////////////////*/

    function create(
        string memory name,
        string memory symbol,
        TAO.tier[] memory tiers,
        uint max_total,
        uint reserve, 
        address guild,
        bool soulbound
    ) public {
        TAO tao = new TAO(
            name, 
            _symbol,
            tiers,
            initiator,
            max_total,
            reserve,
            guild.
            soulbound
        );

        guildDeployed[guild].push(tao);

        emit TAOCreated(guild, address(tao));
    }

    /*///////////////////////////////////////////////////////////////
                                DISPLAY
    ///////////////////////////////////////////////////////////////*/

    function displayTAOs(address guild) public view returns (TAO[] memory) {
        return guildDeployed[guild];
    }

}