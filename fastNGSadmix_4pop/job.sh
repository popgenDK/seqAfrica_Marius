#!/bin/bash
module load  /projects/scarball/apps/Modules/modulefiles/bcftools/1.16
module load plink/1.9.0
module load gcc/11.2.0
module load R/4.2.2
module load R-packages
export R_LIBS="~/Software/R/library"

ln -s ../fastNGSadmix_9pop/ind71.ref.bed .
ln -s ../fastNGSadmix_9pop/ind71.ref.bim .
cp ../fastNGSadmix_9pop/ind71.ref.fam .
sed -i.bak  -e 's/West_African/Northern/g' -e 's/Kordofan/Northern/g' -e 's/Nubian/Northern/g' ind71.ref.fam 
sed -i.bak  -e 's/Masai_Selous/Masai/g'  ind71.ref.fam 
sed -i.bak  -e 's/Southern_African/Southern/g' -e 's/Southern_Central/Southern/g' -e 's/Angolan/Southern/g'  ind71.ref.fam 

# make ref panel
Rscript ~/Software/fastNGSadmix/R/plinkToRef.R ind71.ref


### loop to generate plink file per sample
ref=/maps/projects/seqafrica/people/pls394/others/Marius/fastNGSadmix_4pop/refPanel_ind71.ref.txt
pop=/maps/projects/seqafrica/people/pls394/others/Marius/fastNGSadmix_4pop/nInd_ind71.ref.txt
for fam in $(awk '{print $2}' RothschildsGiraffe_GCam_variable_sites_mergeOJoh_nomultiallelics_noindels_10dp_2het.fam  | grep "GCamCaP" | sort | uniq );
do
     cat RothschildsGiraffe_GCam_variable_sites_mergeOJoh_nomultiallelics_noindels_10dp_2het.fam | grep $fam | plink --bfile ./RothschildsGiraffe_GCam_variable_sites_mergeOJoh_nomultiallelics_noindels_10dp_2het  --keep /dev/stdin --extract ind71.ref.bim --make-bed --allow-extra-chr  --keep-allele-order  --out ${fam}.final;
    ~/Software/fastNGSadmix/fastNGSadmix -plink ${fam}.final  -fname $ref  -Nname $pop  -out ${fam}.full -whichPops Southern,Reticulated,Masai,Northern

done


for i in *qopt; do sample=$(echo $i | sed 's/\.thin\.qopt//g'); echo  -n -e "$sample\t";  cat $i | tail -n1; done > summary.Q
cat header.txt summary.Q > summary.forplot.Q 

