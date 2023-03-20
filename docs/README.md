# nf-core/netseq: Documentation

The nf-core/netseq documentation is split into the following pages:

- [Usage](usage.md)
  - An overview of how the pipeline works, how to run it and a description of all of the different command-line flags.
- [Output](output.md)
  - An overview of the different results produced by the pipeline and how to interpret them.

You can find a lot more documentation about installing, configuring and running nf-core pipelines on the website: [https://nf-co.re](https://nf-co.re)


# nf-core/chipseq: Documentation

The nf-core/chipseq documentation is split into the following pages:

- [Usage](usage.md)
  - An overview of how the pipeline works, how to run it and a description of all of the different command-line flags.
- [Output](output.md)
  - An overview of the different results produced by the pipeline and how to interpret them.

You can find a lot more documentation about installing, configuring and running nf-core pipelines on the website: [https://nf-co.re](https://nf-co.re)



For Netseq:
MNZ: Seqtk should be added, there are 4 versions in nf-core modules. which module do we use?/ MNZ 20230203: module of seqtk-trimfq is written and added

MNZ: Trimmomatic does not support custom adapter,so I added FASTP. 

MNZ: Peter asked to add some extra code for knowing the coverage and how many reads are available after all trimming.


MNZ 13.02.2023: I replaced the 'null' value of following parmeters in 'nextflow.config' with:

MNZ: input 
'/mnt/picea/home/mshemirani/nf-core-netseqpilot/test_result/pipeline_info/samplesheet.valid.csv' to check if it gets our Arabidopsis data

MNZ: genome 'null' with '/mnt/picea/home/mshemirani/nftest/template/Arabidopsis-thaliana/AtRTD2/indeces/salmon/AtRTD2_QUASI_gentrome_salmon_v1dot4dot0'

MNZ: multiqc_config             = '/mnt/picea/home/mshemirani/nf-core-netseqpilot/test_result'

MNZ: outdir                     = '/mnt/picea/home/mshemirani/nf-core-netseqpilot/test_result'

MNZ: do we need to add the following to the workflow?
// Adapter file
    adapter                    = '/mnt/picea/home/mshemirani/nftest/template/reference/Illumina/adapters/TruSeq-PE.fa'
    
MNZ: // rRNA file/folder
    fasta (This is file)                    ='/mnt/picea/home/mshemirani/nftest/template/reference/rRNA/sortmerna/v4.3.4/fasta/smr_v4.3_fast_db.fasta'
    
    indices (MUST be specified as folder)                   ='/mnt/picea/home/mshemirani/nftest/template/reference/rRNA/sortmerna/v4.3.4/indices/smr_v4.3_fast.db'

MNZ: 16-03-2023, 
A config file was created with the name 'upsc.config' and added to the 'conf' directory. (conf/upsc.config). This was included in 'nextflow.config' file at 'profile' section. the two parameters which were 'unknown'  for the pipeline (i.e. 'mailType and account') were included in the 'schema_ignore_params' section. Here we allocated memory, project number and email for receiving email.

