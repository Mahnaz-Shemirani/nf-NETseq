nextflow run \
    nf-core-netseq \
    -profile singularity,upsc
    -params-file params.yml
    
OR
nextflow run \
    nf-core-netseq \
    --input samplesheet.csv \
    --fasta Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa.gz \
    --gtf Homo_sapiens.GRCh38.108.gtf.gz \
    --save_reference \
    <OTHER_PARAMETERS>


OR after saving the references needed for the pipeline
nextflow run \
    nf-core/rnaseq \
    --input samplesheet.csv \
    --fasta Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa.gz \
    --gtf Homo_sapiens.GRCh38.108.gtf.gz \
    --star_index /path/to/moved/star/directory/ \
    --gene_bed /path/to/moved/genes.bed \
    <OTHER_PARAMETERS>

params.yml:
input: '/<path>/<to>/<data>/input'
igenomes_base: '/<path>/<to>/<data>/igenomes'