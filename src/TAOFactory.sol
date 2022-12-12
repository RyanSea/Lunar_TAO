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
        initiator = _initiator;
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
    

    /// @notice creates TAO.sol contract
    /// @param name of token
    /// @param symbol of token
    /// @param tiers for purchasing
    /// @param max_total supply
    /// @param reserve for guild
    /// @param guild address
    /// @param blacksky address
    /// @param soulbound bool
    function create(
        string memory name,
        string memory symbol,
        TAO.Tier[] memory tiers,
        uint max_total,
        uint reserve, 
        address guild,
        address blacksky,
        bool soulbound
    ) public returns (address) {
        TAO tao = new TAO(
            name, 
            symbol,
            tiers,
            initiator,
            max_total,
            reserve,
            guild,
            blacksky,
            soulbound
        );

        guildDeployed[guild].push(tao);

        emit TAOCreated(guild, address(tao));

        return address(tao);
    }

    /*///////////////////////////////////////////////////////////////
                                DISPLAY
    ///////////////////////////////////////////////////////////////*/

    /// @notice returns all TAO's deployed by guild
    function displayTAOs(address guild) public view returns (TAO[] memory) {
        return guildDeployed[guild];
    }

}