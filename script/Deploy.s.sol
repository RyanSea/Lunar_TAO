// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "src/TAOFactory.sol";
import "src/Initiation.sol";

contract Deploy is Script {


    string  tao1_tier1;
    string  tao1_tier2;
    string  tao1_tier3;

    address guild;
    address blacksky;

    string template = "data:application/json;base64,";

    TAOFactory factory;
    
    function setUp() public {

        tao1_tier1 = "data:application/json;base64,eyJuYW1lIjoiVEFPIDEg4oCUIFRpZXIgMSIsImltYWdlIjoiaHR0cHM6Ly9maWxlcy5wZWFrZC5jb20vZmlsZS9wZWFrZC1oaXZlL2F1dG9jcmF0L0FKZWFpWEVlVnREZWRkOEhIeUR1Zml1eEx6MWRkTERZOG8zbVhtYWZIWE5ld1lnWjVqWVB1Zkp1WU52WHUxNy5qcGVnIn0=";
        tao1_tier2 = "data:application/json;base64,eyJuYW1lIjoiVEFPIDEg4oCUIFRpZXIgMiIsImltYWdlIjoiaHR0cHM6Ly9maWxlcy5wZWFrZC5jb20vZmlsZS9wZWFrZC1oaXZlL2F1dG9jcmF0LzIzdFJ0RFFWWU5kNlBZZ3ZkUGR0RjNWNXZCVmpWM0txVUpvMjV0REs0SG9mUHZQQVlYbU5MMWpBMUozbnA1S1JZTWtvcS5qcGcifQ==";
        tao1_tier3 = "data:application/json;base64,eyJuYW1lIjoiVEFPIDEg4oCUIFRpZXIgMyIsImltYWdlIjoiaHR0cHM6Ly9maWxlcy5wZWFrZC5jb20vZmlsZS9wZWFrZC1oaXZlL2F1dG9jcmF0L0VueW41NE13c3Y2N0N6a1REWTlSd2F0eUdyVW80U2tqQml2eFROcjg2TlFYVkVyUmplMm5idGdEZ1kxMUxZb0FrOG8uanBlZyJ9";

        guild = 0x44B269491f4ed800621433cd79bCF62319593C9e;
        blacksky = 0x6EE6D1DF5E2DccD784f7a4bf8eCE5Dbc1babBD45;

    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address initator = address(new Initiation());

        factory = new TAOFactory(initator);

        TAO.Tier[] memory tiers = new TAO.Tier[](3);
        tiers[0] = TAO.Tier(tao1_tier1, .005 ether);
        tiers[1] = TAO.Tier(tao1_tier2, .003 ether);
        tiers[2] = TAO.Tier(tao1_tier3, .001 ether);

        address tao1 = factory.create(
            "TAO One", 
            "TAO1", 
            tiers, 
            100, 
            10, 
            guild, 
            blacksky, 
            false
        );

        console.log("TAO 1", tao1);
        console.log("INITIATOR",initator);

        vm.stopBroadcast();

    }

}



