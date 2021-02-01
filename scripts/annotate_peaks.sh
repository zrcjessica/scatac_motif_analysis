/iblm/netapp/home/jezhou/homer/bin/annotatePeaks.pl \
tss $2 -size -500,250 -m $1 1> $3 2> $4

echo $1/*/*.motif

for m in $1/*/*.motif; do
	echo $m
	if [[ ! -f $m.tsv ]]
	then
		/iblm/netapp/home/jezhou/homer/bin/annotatePeaks.pl \
		tss $2 -size -500,250 -m $m \
		1> $3 2> $4
	fi
done