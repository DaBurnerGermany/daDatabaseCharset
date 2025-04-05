
# daDatabaseCharset

A script that fixes your Collations for some FiveM-myScripts Scripts. 

Error:
```
Illegal mix of collations (xyz) and (xyz2) for operation...
```

Example:
```
Illegal mix of collations (utf8mb4_unicode_ci,IMPLICIT) and (utf8mb4_general_ci,IMPLICIT) for operation...
```


## What to do?
1. check for the error "Illegal mix of collations (xyz) and (xyz2) for operation..." 
2. open the config.lua and edit your charset and collation.. 
- for the Example on the top it would be utf8mb4_unicode_ci as collation and utf8mb4 as charset.
3. once start the Script and check if there are any Errors
- If the script prints "now check if your script works ;)" on the live-console the script is finished
