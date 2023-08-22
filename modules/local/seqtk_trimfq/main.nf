// To use this module in paird-end mode first define the input chanel in the work flow with transpose() and remeber that the next step only get single-end input while the meta is paired-end therefore use groupTuple() for the next tool

process SEQTK_TRIMFQ {
    tag "$meta.id"
    label 'process_medium'


    conda "bioconda::seqtk=1.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/seqtk:1.3--h5bf99c6_3':
        'quay.io/biocontainers/seqtk:1.3--h5bf99c6_3' }"

    input:
    tuple val(meta), path(reads)
    val (trim_beginning)
    val (trim_end)

    output:
    tuple val(meta), path('*.gz')            , emit: reads
    path "versions.yml"                      , emit: versions


    when:
    task.ext.when == null || task.ext.when


    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    seqtk \\
        trimfq \\
        -b $trim_beginning \\
        -e $trim_end \\
        $reads | \\
        gzip -c > "${reads.simpleName}.seqtk-trim.fastq.gz"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        seqtk: \$(echo \$(seqtk 2>&1) | sed 's/^.*Version: //; s/ .*\$//')
    END_VERSIONS
    """

}
