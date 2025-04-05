
MySQL.ready(function()

    print("This only runs cuz you don't know how to administer you database :) ... ")

    print("Starting to fix your fcking database...")
    print("Check if your Version can handle utf8mb3 or you use a old af version...")

    local Runs = {
        {Charset= 'utf8mb3', Collation = 'utf8mb3_unicode_ci'},
        {Charset= ResultCharset.Charset , Collation = ResultCharset.Collation}
    }

    local query = "SHOW CHARACTER SET LIKE 'utf8mb3'"
    local data = MySQL.Sync.fetchAll(query,{})

    if #data>0 then 
        print("Wow, current database version!")
    else
        print("your database does not support utf8mb3, old af lol")

        Runs = {
            {Charset= 'utf8', Collation = 'utf8_unicode_ci'},
            {Charset= ResultCharset.Charset , Collation = ResultCharset.Collation}
        }
    end 

    
    print("Start to change charsets")

    for runcounter,runData in pairs(Runs) do 

        print("Step " .. runcounter .. ".. Change tables to " .. runData.Collation)
		
		for tablekey, tablename in pairs(Tables) do
			finaltable = tablename
			local query = ""
			
			if isSearch(tablename) then
		
				finaltable = string.gsub(tablename, "%%", "") 
			
				query = [[
					select TABLE_NAME from information_schema.tables where TABLE_SCHEMA = database() AND TABLE_NAME LIKE CONCAT(@tablename,'%') and TABLE_COLLATION <> @collation
				]]
			else
				query = [[
					select TABLE_NAME from information_schema.tables where TABLE_SCHEMA = database() AND TABLE_NAME LIKE CONCAT(@tablename) and TABLE_COLLATION <> @collation
				]]
			end 
			
			local data = MySQL.Sync.fetchAll(query,{
				["@collation"] = runData.Collation,
				["@tablename"] = finaltable,
			})
			
			
			print("found " .. #data .. "tables.. tablesearch =>  " .. tablename)
			
			if #data>0 then
				for k,v in pairs(data) do
					
					query = "ALTER TABLE `" .. v.TABLE_NAME .. "` CONVERT TO CHARACTER SET " .. runData.Charset .. " COLLATE " .. runData.Collation
				
					MySQL.Sync.execute(query, {})
				end
		
				print("[INFO] " .. tostring(#data) .. " tables changed")
			else
				print("[INFO] 0 tables changed")
			end 
		
			if isSearch(tablename) then
				query = [[
					SELECT
						table_name, 
						column_name, 
						character_set_name, 
						collation_name, 
						COLUMN_TYPE,
						COLUMN_DEFAULT, 
						IS_NULLABLE
					FROM information_schema.columns
					WHERE TABLE_SCHEMA = database()
						AND TABLE_NAME like CONCAT(@tablename,'%')
						and (character_set_name <> @charset
						OR collation_name <> @collation)
				]]
			else
				query = [[
					SELECT
						table_name, 
						column_name, 
						character_set_name, 
						collation_name, 
						COLUMN_TYPE,
						COLUMN_DEFAULT, 
						IS_NULLABLE
					FROM information_schema.columns
					WHERE TABLE_SCHEMA = database()
						AND TABLE_NAME like CONCAT(@tablename)
						and (character_set_name <> @charset
						OR collation_name <> @collation)
				]]
			end 
		
			data = MySQL.Sync.fetchAll(query,{
					["@tablename"] =  finaltable,
					["@charset"] =  runData.Charset,
					["@collation"] = runData.Collation
			})
			
			
			print("found " .. #data .. " columns.. tablesearch =>  " .. tablename)
			
			if #data>0 then
				for k,v in pairs(data) do
					local isnullable = ""
					local defaultval = ""
		
					if v.IS_NULLABLE == "NO" then 
						isnullable = " NOT NULL"
					end 
					if v.COLUMN_DEFAULT ~= nil then 
						defaultval = " DEFAULT " .. v.COLUMN_DEFAULT
					end 
		
					local updateQuery = "" .. 
						" ALTER TABLE `" .. v.table_name .. 
						"` CHANGE COLUMN `" .. v.column_name .. "` `" .. v.column_name .. "` " .. v.COLUMN_TYPE .. " CHARACTER SET @charset COLLATE @collation " .. isnullable .. defaultval
		
					MySQL.Sync.execute(updateQuery, {
						["@charset"] = runData.Charset
						,["@collation"] = runData.Collation
					})
				end
		
				print("[INFO] " .. tostring(#data) .. " columns changed")
			else
				print("[INFO] 0 columns changed")
			end
		end 
    end 

    print("now check if your script works ;)")

end)


function isSearch(str)
	if string.find(str, "%%") then
		return true
	else
		return false
	end
end 