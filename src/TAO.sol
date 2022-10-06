// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @dev commented out tokenURI function
import "solmate/tokens/ERC721.sol";

import "forge-std/Test.sol";

contract TAO_NFT is ERC721 {
    
    /*///////////////////////////////////////////////////////////////
                            INITIALIZATION
    //////////////////////////////////////////////////////////////*/

    /// @notice whether or not nft's are soulbound
    bool public immutable soulbound;

    /// @notice max total nft's 
    uint public immutable max_total;

    /// @notice amount reserved to guild
    uint public reserve;

    /// @notice array of tiers
    /// @dev front-end needs to sort by minimum in decending order
    tier[] public tiers;

    /// @notice initiation contract
    address public immutable initiator;

    /// @notice guild multisig
    address public guild;

    constructor(
        string memory _name, 
        string memory _symbol,
        tier[] memory _tiers,
        address _initatior,
        uint _max_total,
        uint _reserve,
        address _guild,
        bool _soulbound
    ) ERC721(_name, _symbol) {
        // question: can there even be an empty _tiers?
        require(_tiers.length > 0, "EMPTY_TIERS");

        soulbound = _soulbound;

        max_total = _max_total;

        initiator = _initatior;

        reserve = _reserve;

        guild = _guild;
         
        for (uint i; i < _tiers.length; ) {
            tiers.push(_tiers[i]);

            unchecked { ++i; }
        }
    }

    /// @notice uri tier for minimum purchase amount
    struct tier {
        string uri; 
        uint minimum;
    }

    /// @notice nft id counter
    uint public id;

    /// @notice nft id => uri
    mapping (uint256 => string) public tokenURI;

    /// @notice address => id they own
    /// temp for testing
    mapping(address => uint) public idOwned;

    /*///////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event Minted(address indexed to, uint indexed id, uint value);  

    event GuildClaimed(uint indexed starting_id, uint indexed ending_id);

    /*///////////////////////////////////////////////////////////////
                                MINTING
    //////////////////////////////////////////////////////////////*/

    /// @notice mints single nft
    function mint(address to, uint value) public returns (bool success) {
        require(msg.sender == initiator, "NOT_INITIATOR");

        require(balanceOf(to) == 0, "ALREADY_INITIATED");

        // save tiers to memory
        tier[] memory _tiers = tiers;

        // note: can't underflow, there must be at least 1 tier
        unchecked { require(value >= _tiers[_tiers.length - 1].minimum, "MINIMUM_UNMET"); }

        // increment id & save to memory
        uint _id = ++id;

        require(_id + reserve <= max_total, "MAX_MINTED"); 

        // select highest qualifying tier
        for (uint i; i < _tiers.length; ) {
            if (value >= _tiers[i].minimum) {
                _mint(to, _id);
                
                // temp for testing
                idOwned[to] = _id;

                tokenURI[_id] = _tiers[i].uri;

                break;
            } else {
                unchecked { ++i; }
            }
        }

        success = true;

        emit Minted(to, _id, value);
    }

    /// @notice batch-mints multiple NFT's to guild
    function guildClaim(uint amount) public returns (bool success) {
        require(msg.sender == guild, "NOT_GUILD");

        // save reserve to memory
        uint _reserve = reserve;

        require(_reserve >= amount, "INSUFFICIENT_RESERVE");

        // update reserve
        // note: can't underflow
        unchecked { reserve = _reserve - amount; }

        // save to tiers to memory
        tier[] memory _tiers = tiers;

        string memory uri;

        // select lowest tier uri
        // note: can't underflow, there must be at least 1 tier
        unchecked { uri = _tiers[_tiers.length - 1].uri; }

        // save id to memory
        uint _id = id;

        // batch mint
        for (uint i; i < amount; ) {
            unchecked { _mint(msg.sender, ++_id); }

            tokenURI[_id] = uri;

            unchecked { ++i; }
        }

        // update id
        id = _id;

        success = true;

        emit GuildClaimed(_id - amount + 1, _id);
    }

    /// @notice mint's nft from guild's reserve to another account
    function guildMint(address to, uint tier_index) public {
        require(msg.sender == guild, "NOT_GUILD");

        require(balanceOf(to) == 0, "ALREADY_INITIATED");

        require(reserve >= 1, "INSUFFICIENT_RESERVE");

        --reserve;

        // get uri from tier_index
        string memory uri = tiers[tier_index].uri;

        uint _id;

        // increment id and save to memory
        unchecked { _id = ++id; }

        _mint(to, _id);

        tokenURI[_id] = uri;
    }

    /*///////////////////////////////////////////////////////////////
                                TRANSFER
    //////////////////////////////////////////////////////////////*/

    /// @notice transfers nft from guild's treasury
    function guildTransfer(
        address to,
        uint _id,
        uint tier_index
    ) public {
        require(msg.sender == guild, "NOT_GUILD");

        require(balanceOf(to) == 0, "ALREADY_INITIATED");

        // get uri from tier index
        string memory uri = tiers[tier_index].uri;

        // set new uri
        tokenURI[_id] = uri;

        super.safeTransferFrom(msg.sender, to, _id);
    }

    /*///////////////////////////////////////////////////////////////
                                SOULBOUND
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        address from,
        address to,
        uint256 _id
    ) public virtual override {
        if (soulbound) {
            revert("SOULBOUND");
        } else {
            super.safeTransferFrom(from, to, _id);
        }
        
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 _id,
        bytes calldata data
    ) public virtual override {
        if (soulbound) {
            revert("SOULBOUND");
        } else {
            super.safeTransferFrom(from, to, _id, data);
        }
        
    }

}
