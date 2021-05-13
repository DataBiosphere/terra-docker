#!/bin/bash

export GATK_FROZEN_MODEL="/home/jupyter-user/models/broad_frozen_model.pb"
export GATK_INF_METHOD="keras"

gatk CNNScoreVariants \
        -I data/g94982_chr20_1m_10m_bamout.bam \
        -V data/g94982_b37_chr20_1m_15871.vcf.gz \
        -R data/Homo_sapiens_assembly19.fasta \
        -O data/my_2d_cnn_scored.vcf \
        --tensor-type read_tensor \
        --transfer-batch-size 256 \
        --inference-batch-size 256
