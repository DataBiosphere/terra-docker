#!/bin/bash

gatk CNNScoreVariants \
        -I gs://gatk-tutorials/workshop_2002/2-germline/CNNScoreVariants/bams/g94982_chr20_1m_10m_bamout.bam \
        -V gs://gatk-tutorials/workshop_2002/2-germline/CNNScoreVariants/vcfs/g94982_b37_chr20_1m_15871.vcf.gz \
        -R gs://gcp-public-data--broad-references/hg19/v0/Homo_sapiens_assembly19.fasta \
        -O my_2d_cnn_scored.vcf \
        --tensor-type read_tensor \
        --transfer-batch-size 256 \
        --inference-batch-size 256
