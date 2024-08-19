#!/bin/bash
module load  /projects/scarball/apps/Modules/modulefiles/bcftools/1.16
module load plink/1.9.0
module load gcc/11.2.0
module load R/4.2.2
module load R-packages
export R_LIBS="~/Software/R/library"

INVCF=/maps/projects/seqafrica/people/pls394/others/Marius/GT_new/results/giraffe/vcf/RothschildsGiraffe_GCam_variable_sites_mergeOJoh_nomultiallelics_noindels_10dp_2het.bcf.gz
bcftools query -f '%CHROM\t%POS\t%ID\t%REF\t%ALT\n' $INVCF > RothschildsGiraffe_GCam_variable_sites_mergeOJoh_nomultiallelics_noindels_10dp_2het.info

# --a2-allele <uncompressed VCF filename> 4 3 '#', see https://www.cog-genomics.org/plink/1.9/data#ax_allele
# fix a2 as ref
plink -bcf $INVCF  --allow-extra-chr --const-fid 0   --set-missing-var-ids "@:#:\$1:\$2" --a2-allele RothschildsGiraffe_GCam_variable_sites_mergeOJoh_nomultiallelics_noindels_10dp_2het.info  4 3 '#'    --make-bed --out ./RothschildsGiraffe_GCam_variable_sites_mergeOJoh_nomultiallelics_noindels_10dp_2het

plink --bfile RothschildsGiraffe_GCam_variable_sites_mergeOJoh_nomultiallelics_noindels_10dp_2het --keep ind71.ref.keep  --keep-allele-order --allow-extra-chr --maf 0.00001 --make-bed --out ind71.ref

# update ind71.ref.fam based on  /maps/projects/seqafrica/people/pls394/others/Marius/fastNGSadmix_invalid/thin_ref.fam

# make ref panel
Rscript ~/Software/fastNGSadmix/R/plinkToRef.R ind71.ref


### loop to generate plink file per sample
ref=/maps/projects/seqafrica/people/pls394/others/Marius/fastNGSadmix_9pop/refPanel_ind71.ref.txt
pop=/maps/projects/seqafrica/people/pls394/others/Marius/fastNGSadmix_9pop/nInd_ind71.ref.txt
for fam in $(awk '{print $2}' RothschildsGiraffe_GCam_variable_sites_mergeOJoh_nomultiallelics_noindels_10dp_2het.fam  | grep "GCamCaP" | sort | uniq );
do
    # cat RothschildsGiraffe_GCam_variable_sites_mergeOJoh_nomultiallelics_noindels_10dp_2het.fam | grep $fam | plink --bfile ./RothschildsGiraffe_GCam_variable_sites_mergeOJoh_nomultiallelics_noindels_10dp_2het  --keep /dev/stdin --extract ind71.ref.bim --make-bed --allow-extra-chr  --keep-allele-order  --out ${fam}.final;
    ~/Software/fastNGSadmix/fastNGSadmix -plink ${fam}.final  -fname $ref  -Nname $pop  -out ${fam}.full -whichPops Nubian,Reticulated,Masai,Southern_Central,Southern_African,Angolan,West_African,Masai_Selous,Kordofan
    

done


for i in *qopt; do sample=$(echo $i | sed 's/\.thin\.qopt//g'); echo  -n -e "$sample\t";  cat $i | tail -n1; done > summary.Q
cat header.txt summary.Q > summary.forplot.Q 

