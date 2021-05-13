#!/bin/bash

mkdir data
gsutil cp gs://gatk-tutorials/workshop_2002/2-germline/CNNScoreVariants/bams/g94982_chr20_1m_10m_bamout.bam data/.
gsutil cp gs://gatk-tutorials/workshop_2002/2-germline/CNNScoreVariants/bams/g94982_chr20_1m_10m_bamout.bai data/.
gsutil cp gs://gatk-tutorials/workshop_2002/2-germline/CNNScoreVariants/vcfs/g94982_b37_chr20_1m_15871.vcf.gz data/.
gsutil cp gs://gatk-tutorials/workshop_2002/2-germline/CNNScoreVariants/vcfs/g94982_b37_chr20_1m_15871.vcf.gz.tbi data/.
gsutil cp gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.fasta data/.
gsutil cp gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.fasta.fai data/.
gsutil cp gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.dict data/.
