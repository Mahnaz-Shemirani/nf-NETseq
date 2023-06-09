process SEQTK_TRIMFQ {
    tag "$meta.id"
    label 'process_medium'


    conda "bioconda::seqtk=1.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/seqtk:1.3--h5bf99c6_3':
        'quay.io/biocontainers/seqtk:1.3--h5bf99c6_3' }"

    input:
    tuple val(meta), path(reads)
    val trim_begining
    val trim_end

    output:
    tuple val(meta), path("*.fq.gz"), emit: reads
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    if ( !trim_begining ) {
        error "SEQTK/TRIM must have a triming size value included for the beginign of the read"
    }
    if ( !trim_end ) {
        error "SEQTK/TRIM must have a triming size value included for the end of the read"
    }
    """
    seqtk \\
        trimfq \\
        $args \\
        -b $trim_begining \\
        -e $trim_end \\
        $reads \\
        | gzip -c > ${prefix}.sektk_trim.fq.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        trimfq: \$(echo \$(seqtk --version 2>&1) | sed 's/^.*seqtk //; s/Using.*\$//' ))
    END_VERSIONS
    """
}
