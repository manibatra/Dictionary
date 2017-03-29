gsed '/^.\{,2\}$/d' words.txt >> words3.txt

for x in {a..z}
do
   grep -ow "$x\w*" words3.txt >> $x.txt
done
