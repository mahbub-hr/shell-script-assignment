#!/bin/bash
unzip SubmissionsAll.zip
rm -i -v -f SubmissionsAll.zip
rm -i -v -f marks.txt
find -name "*.zip"|awk -F'[_]' '{print $5}'|cut -d '.' -f 1 > present.txt
sort present.txt -o  present.txt
cat CSE_322.csv|tr -d '\t''"' > allwithname.txt 
#cut -d ',' -f 1 CSE_322.csv|  cut -d '"' -f 2 CSE_322.csv
cat CSE_322.csv|awk -F'[\t,"]' '{print $3}' > all.txt
sort all.txt -o  all.txt
comm -23 --check-order all.txt present.txt > absents.txt

mkdir Output
mkdir Output/extra

#cwd=$PWD
#ls -ld Output/* |wc -l #count number of subdirectories



for f in *.zip; do
	
	mkdir temp
	unzip "$f" -d temp
	dirs="$(ls -ld temp/* |wc -l)"
	one=1
	
	if [ "$dirs" -eq "$one" ]; then    #single subdirectories
	
		#echo 'finally i made it done'
		sid1="$(find ./temp/*  -maxdepth 0 -type d|cut -d/ -f3)"
		#echo $sid1
		found1="$(grep -c "$sid1" all.txt)"
		
		sid2="$(echo "$sid1"|cut -d "_" -f1)"
		#echo $sid2
		found2="$(grep -c "$sid2" all.txt)"
		#echo $found2
			
		if [ "$found1" -eq "1" ]; then
			echo ""$sid1"		10" >> marks.txt
			mv -v ./temp/"$sid1"  ./Output/"$sid1"
			
		elif [ "$found2" -eq "1" ]; then
			mv temp/"$sid1" temp/"$sid2"
			mv -v ./temp/*  ./Output/
			echo ""$sid2"		5" >> marks.txt
		
		else
			sid3="$(echo "$f"|awk -F'[_]' '{print $5}'|cut -d '.' -f 1)" #get sid from zip file
		#	echo  $id 
			found3="$(grep -c "$sid3" all.txt)"
			
			if [ "$found3" -eq "1" ]; then
				mv temp/"$sid1" temp/"$sid3"
				mv -v ./temp/*  ./Output/
				echo ""$sid3"		0" >> marks.txt
				
			else #can not get id from .zip
				sname="$(echo "$f"|awk -F'[_]' '{print $1}')"
				echo $sname
				
				tcount="$(grep -i -c "$sname" CSE_322.csv)"	#search with name
				
				echo "tcount="$tcount""
				
				if [ "$tcount" -eq "1" ]; then
					sid4="$(grep -i "$sname" allwithname.txt | cut -d, -f1)"
					echo "$sid4"
					mv temp/"$sid1" temp/"$sid4"
					mv -v ./temp/*  ./Output/
					echo ""$sid4"		0" >> marks.txt
					grep -v "$sid4" absents.txt > abs.txt ; mv abs.txt absents.txt #remove from absents list
					
				else	#multiple id with same name
					
					sid4="$(grep -i "$sname" allwithname.txt | cut -d, -f1)"
					v=0
					roll=0
					for j in ${sid4[@]}; do
					
					echo "j is $j"
						
						if [ "$(grep -c "$j" absents.txt)" -eq "1" ]; then
						 	
						 	if [ "$v" -eq "1" ];then
						 		v=2
						 		break
						 	fi
						 	
							v=1
							roll=$j
							echo "roll is = $roll"
						fi
					
					done
					
					if [ "$v" -eq "1" ]; then
					
						mv -v temp/"$sid1" temp/"$roll"
						mv -v ./temp/*  ./Output/
						echo ""$roll"		0" >> marks.txt
						grep -v "$roll" absents.txt > abs.txt ; mv abs.txt absents.txt #remove from absents list
						
					else
						mv -v temp/"$sid1" temp/"$sname"
						mv -v ./temp/*  ./Output/extra
					fi
				
				fi
				
			fi
				
		fi
		
	rm -r temp
		
	else								#multiple subdirectories
	
		id="$(echo "$f"|awk -F'[_]' '{print $5}'|cut -d '.' -f 1)" #get sid from zip file
		echo  $id 
		found3="$(grep -c "$id" all.txt)"
		
		if [ "$found3" -eq "1" ]; then
			mv temp "$id"
			mv -v ./"$id"  ./Output/
			echo ""$id"		0" >> marks.txt
			
		else #can not get id from .zip
		
			sname="$(echo "$f"|awk -F'[_]' '{print $1}')"
			echo $sname
			
			tcount="$(grep -i -c "$sname" CSE_322.csv)"	#search with name
			
			if [ "$tcount" -eq "1" ]; then
			
				sid4="$(grep -i "$sname" allwithname.txt | cut -d, -f1)"
				mv -v temp "$sid4"
				mv -v ./"$sid4"  ./Output/
				echo ""$sid4"		0" >> marks.txt
				grep -v "$sid4" absents.txt > abs.txt ; mv abs.txt absents.txt
				
			else	#multiple id with same name
			
				sid4="$(grep -i "$sname" allwithname.txt | cut -d, -f1)"
					v=0
					roll=0
					for j in ${sid4[@]}; do
						
						if [ "$(grep -c "$j" absents.txt)" -eq "1" ]; then
						 	
						 	if [ "$v" -eq "1" ];then
						 		v=2
						 		break
						 	fi
						 	
							v=1
							roll=$j
							echo "roll is = $roll"
						fi
					
					done
					
					if [ "$v" -eq "1" ]; then
					
						mv -v temp "$roll"
						mv -v ./"$roll"  ./Output/
						echo ""$roll"		0" >> marks.txt
						grep -v "$roll" absents.txt > abs.txt ; mv abs.txt absents.txt #remove from absents list
						
					else
						mv -v temp "$sname"
						mv -v ./"$sname"  ./Output/extra
					fi
				
			
			fi
			
		fi
	
	fi
	
rm "$f"
	#find ./Ouput -mindepth 2 -maxdepth 2 -type d|cut -d/ -f3
done

awk -i inplace '{FS="\t\t";OFS="\t\t"; print  $1, '0';}'  absents.txt
cat marks.txt absents.txt > abs.txt
mv abs.txt marks.txt
sort marks.txt	-o marks.txt
rm *.rar


