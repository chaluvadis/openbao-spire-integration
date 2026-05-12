~ $ bao operator init
Unseal Key 1: eG5Hr1RB+T1+67wMxrzVVo8pT402KFGYco8EMFGxsDwf
Unseal Key 2: ipn2YDuRARzKVhyl2YKBDILLOHtV+1bp6gk8b5eAR7Pe
Unseal Key 3: Y6pzSLccojIyEnT0wcRk+1RSCpiBp1s7pJo//T2Kmu8g
Unseal Key 4: w4VQHNLkoLS7C1TrMU9X5zbM18KFoTdKSkJGSYfILpG9
Unseal Key 5: rNdSoBoT8iFAav9AV8nL5vrTKiZiAt7yFchUTSk5/WYX

Initial Root Token: s.4jRPCUuwWnM0rJSZOszNeEP1

Vault initialized with 5 key shares and a key threshold of 3. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 3 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated root key. Without at least 3 keys to
reconstruct the root key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum
of existing unseal keys shares. See "bao operator rotate-keys" for more
information.
