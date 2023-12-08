// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";


import {OwnableProjectList} from '../../src/projects/OwnableProjectList.sol';
import {OsmoticController} from "../../src/OsmoticController.sol";

contract CreateList is Script {
    OsmoticController controller;
    uint pk;
    string name;
    /**
     * @custom:instructions
     * This script is intended to be used to create a `List`, if you have other needs, please see other scripts that may fit you better.
     * @custom:notice 
     * This script also offers the option of adding projects to the list.
     * Remember that each time you run the script, a new `List` is created. 
     * @custom:notice 
     * In the case you want to add x amount of projectIds, meka sure each value is unique and is a registered project.
     */
    constructor() {
        controller= OsmoticController(vm.envAddress('CONTROLLER'));
        pk=vm.envUint("PK_SENDER");
        name = vm.envString('LIST_NAME');
        addingProjects=false;

    }   
    bool addingProjects;
    uint[] projectIds;

    function run() external virtual  {
        vm.startBroadcast(pk);
        address _list=controller.createProjectList(name);
        if (addingProjects) _addProjects(_list,projectIds);
        vm.stopBroadcast();
    }

    function _addProjects(address _list,uint[] memory _projects)internal  {
        uint l_=_projects.length;
        OwnableProjectList list= OwnableProjectList(_list);
        if (l_==0) return ;
        else if (l_== 1 ) list.addProject(_projects[0]);
        else list.addProjects(_projects);
    }
}

