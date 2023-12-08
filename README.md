# <h1 align="center"> Deploy-scripts </h1>

## Getting Started

In order to be able to use this scripts, please follow the following steps:

1. Enter the terminal and use the command `make install-dep`
```sh
    $ make install-dep
``` 
This will install `OpenZeppelin` contracts (base contracts & upgradeable ones).

2. Create an `.env` file. 
3. Fill the `.env` file with the desired data. It will depend wich script you decide to use, the params that are required to be stored in the file.
4. Set the rpc url in the `foundry.toml`
```foundry.toml
    [rpc_endpoints]
    llhh='http://127.0.0.1:8545'
    mumbai='http://..../${YOUR_API_KEY}'
```
In case you are using other chain that is not localhost, you will need a rpc end point to uploead a transaction into that network. 
