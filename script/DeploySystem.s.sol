// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./ScriptUtils.sol";

contract DeploySystem is ScriptUtils {
    // ManagerConstr mContructor;
    address constant CFA_V1_FORWARDER_ADDRESS = address(0);
    SetupConfig config=SetupConfig({version: 1, roundDuration: 4 weeks, cfaV1Forwarder: CFA_V1_FORWARDER_ADDRESS,nw_owner:address(0)});

    uint VERSION = 1;
    /**
     * @dev Pool contructor values
     */
    address CFA_FORWARDED;
    /**
     * @dev Registry init values
     */
    address REGISTRY_OWNER;
    address REGISTRY_BEACON_OWNER;
    /**
     * @dev Manager init values
     */
    address MANAGER_OWNER;
    address MANAGER_BEACON_OWNER;
    /**
     * @dev Deploy values
     */
    string CHAIN_NAME = "LOCAL_HOST";
    bool isLH = true;

    /**
     * @custom:set-up
     * @custom:env
     * 1. Create a `.env` file (in case you dont have one)
     * 2. Load all variables needed:
     *  - LH_PRIVATE_KEY                (llhh)
     *  - LH_REG_OWNER                  (llhh)
     *  - LH_REG_BEACON_OWNER           (llhh)
     *  - LH_MNGR_OWNER                 (llhh)
     *  - LH_MNGR_BEACON_OWNER          (llhh)
     * 
     *  - DEPLOY_PRIVATE_KEY            (!llhh)
     *  - SAFE_IMPL                     (!llhh)
     *  - DEPLOY_REG_OWNER              (!llhh)
     *  - DEPLOY_REG_BEACON_OWNER       (!llhh)
     *  - DEPLOY_CFA_FORWARDED          (!llhh)
     *  - DEPLOY_MNGR_OWNER             (!llhh)
     *  - DEPLOY_MNGR_BEACON_OWNER      (!llhh)
     * @custom:toml
     * 3. Create the desired profile to the chain you are going to deploy. Ej := llhh
     * [rpc_endpoints]
     * llhh='http://127.0.0.1:8545'
     * 
     * @custom:make
     * 4. create a custom command to deploy all seamesly. 
     * Ej: deploy-all-llhh:
	    forge script script/DeploySystem.s.sol:DeploySystem --rpc-url llhh  --watch -vvvv --broadcast
     *  
     * @custom:deploy
     * 
     * xCHAIN - >[open a terminal]: make deploy-all-xchain (@dev needs to be built)
     * 
     * LLHH   - >[open a terminal]: anvil ${ANVIL_CUSTOMISATION}
     *        - >[open a terminal]: make deploy-all-llhh
     */

    function run() public virtual{
       _run();
    }
    uint pk ;
    function _run() internal virtual {
        // setUpContracts()
        if (isLH) {
            pk=vm.envUint("LH_PRIVATE_KEY");
            // crea un dummy para el llhh
            // _createCFA_llhh()
            config.cfaV1Forwarder=_createCFA_llhh();
            config.nw_owner=vm.envAddress("NEW_OWNER");
            controllerOwner= vm.envAddress("LH_MNGR_OWNER");
            registryOwner= vm.envAddress("LH_MNGR_OWNER");
        }else{
            pk=vm.envUint("DEPLOY_PRIVATE_KEY");
            // aca agarra la direccion de CFA del env
            config.cfaV1Forwarder=vm.envAddress("aCHAIN_CFA");
            controllerOwner= vm.envAddress("MNGR_OWNER");
            registryOwner= vm.envAddress("REG_OWNER");
            config.nw_owner=vm.envAddress("NEW_OWNER");
        }
        console.log(CHAIN_NAME);
        vm.startBroadcast(pk);

        setUpContracts(config);
        

        // vm.stopBroadcast();
    }

    function _transferOwnership(address _newOwner)internal  {
        vm.startBroadcast(pk);
        

        vm.stopBroadcast();
        
    }


    
}
