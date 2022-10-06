// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

//import "forge-std/Test.sol";

import "src/TAO.sol";

import "src/Initiation.sol";

import "./utils/Utils.sol";

contract TAOTest is Test {

    Initiation initiator;

    TAO_NFT nft_x;
    TAO_NFT nft_y;
    TAO_NFT nft_z;

    TAO_NFT.tier[] tiers_x;
    TAO_NFT.tier[] tiers_y;
    TAO_NFT.tier[] tiers_z;


    address guild_x;
    address guild_y;
    address guild_z;

    address ryan;
    address stellar;
    address cryborg;
    address hackermom;
    address hermes;

    Utils utils;

    address payable[] users;


    function setUp() public {

        ///   SET USERS   ///

        utils = new Utils();

        users = utils.createUsers(8);

        guild_x = users[0];
        guild_y = users[1];
        guild_z = users[2];

        ryan = users[3];
        stellar = users[4];
        cryborg = users[5];
        hackermom = users[6];
        hermes = users[7];

        ///   SET INITIALIZER   ///

        initiator = new Initiation();

        ///   SET TIERS   ///

        // TAO X

        tiers_x.push(TAO_NFT.tier("TAO X: Tier 1", 3 ether));
        tiers_x.push(TAO_NFT.tier("TAO X: Tier 2", 1.5 ether));
        tiers_x.push(TAO_NFT.tier("TAO X: Tier 3", .3 ether));

        // TAO Y

        tiers_y.push(TAO_NFT.tier("TAO Y: Tier 1", 5 ether));
        tiers_y.push(TAO_NFT.tier("TAO Y: Tier 2", 4 ether));
        tiers_y.push(TAO_NFT.tier("TAO Y: Tier 3", 3 ether));
        tiers_y.push(TAO_NFT.tier("TAO Y: Tier 4", 2 ether));
        tiers_y.push(TAO_NFT.tier("TAO Y: Tier 5", 1 ether));
        tiers_y.push(TAO_NFT.tier("TAO Y: Tier 6", .5 ether));

        // TAO Z
        
        tiers_z.push(TAO_NFT.tier("TAO Z: Only Tier", .2 ether));

        ///   INITIALIZE TAOS  ///

        nft_x = new TAO_NFT(
            "Guild ",
            "GUI",
            tiers_x,
            address(initiator),
            10,
            3,
            guild_x,
            true
        );

        nft_y = new TAO_NFT(
            "Guild Y TAO",
            "GUILDY",
            tiers_y,
            address(initiator),
            3,
            1,
            guild_y,
            true
        );

        nft_z = new TAO_NFT(
            "Guild Z TAO",
            "GUILDZ",
            tiers_z,
            address(initiator),
            1000,
            300,
            guild_y,
            true
        );


    }

    function testMinting() public {
        // RYAN'S ORDER //
        Initiation.initiation[] memory ryansOrder = new Initiation.initiation[](3);
        ryansOrder[0] = Initiation.initiation(nft_x, 1.5 ether);
        ryansOrder[1] = Initiation.initiation(nft_y, 4.5 ether);
        ryansOrder[2] = Initiation.initiation(nft_z, 1.5 ether);

        vm.prank(ryan);
        initiator.initiate{ value: 7.5 ether }(ryansOrder);

        assertEq(nft_x.tokenURI(nft_x.idOwned(ryan)), "TAO X: Tier 2");
        assertEq(nft_y.tokenURI(nft_y.idOwned(ryan)), "TAO Y: Tier 2");
        assertEq(nft_z.tokenURI(nft_z.idOwned(ryan)), "TAO Z: Only Tier");

        // STELLAR'S ORDER //
        Initiation.initiation[] memory stellarsOrder = new Initiation.initiation[](3);
        stellarsOrder[0] = Initiation.initiation(nft_x, 10 ether);
        stellarsOrder[1] = Initiation.initiation(nft_y, 1.8 ether);
        stellarsOrder[2] = Initiation.initiation(nft_z, 1 ether);

        vm.prank(stellar);
        initiator.initiate{ value: 12.8 ether }(stellarsOrder);

        assertEq(nft_x.tokenURI(nft_x.idOwned(stellar)), "TAO X: Tier 1");
        assertEq(nft_y.tokenURI(nft_y.idOwned(stellar)), "TAO Y: Tier 5");
        assertEq(nft_z.tokenURI(nft_z.idOwned(stellar)), "TAO Z: Only Tier");

        // CRYBORG'S ORDER //
        Initiation.initiation[] memory cryborgsOrder = new Initiation.initiation[](3);
        cryborgsOrder[0] = Initiation.initiation(nft_x, 10 ether);
        cryborgsOrder[1] = Initiation.initiation(nft_y, 10 ether);
        cryborgsOrder[2] = Initiation.initiation(nft_z, 1 ether);

        vm.expectRevert("MAX_MINTED");
        vm.prank(cryborg);
        initiator.initiate{ value: 21 ether }(cryborgsOrder);

        assertEq(nft_x.balanceOf(cryborg), 0);
        assertEq(nft_y.balanceOf(cryborg), 0);
        assertEq(nft_z.balanceOf(cryborg), 0);
    }
}
