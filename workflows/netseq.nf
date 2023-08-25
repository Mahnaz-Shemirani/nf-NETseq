/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters
WorkflowNetseq.initialise(params, log)

// TODO nf-core: Add all file path parameters for the pipeline to the list below
// Check input path parameters to see if they exist
def checkPathParamList = [ params.input, params.multiqc_config, params.adapter_fasta, params.fastas, params.index, params. gtf]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check mandatory parameters
if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }

if (params.fastas) { ch_sortmerna_fastas = Channel.fromPath("${params.fastas}") } else {exit 1, 'Input reference fastas file for sortmerna not specified'}

if (params.adapter_fasta) { ch_adapter_fasta = Channel.fromPath("${params.adapter_fasta}") } else {exit 1, 'Input adapter file not specified'}

if (params.index) { index_ch = Channel.fromPath("${params.index}") } else {exit 1, 'Input index directory for STAR alignment not specified'}

if (params. gtf) { gtf_ch   = Channel.fromPath("${params.gtf}") } else {exit 1, 'Input gtf file for STAR alignment not specified'}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

ch_multiqc_config          = Channel.fromPath("$projectDir/assets/multiqc_config.yml", checkIfExists: true)
ch_multiqc_custom_config   = params.multiqc_config ? Channel.fromPath( params.multiqc_config, checkIfExists: true ) : Channel.empty()
ch_multiqc_logo            = params.multiqc_logo   ? Channel.fromPath( params.multiqc_logo, checkIfExists: true ) : Channel.empty()
ch_multiqc_custom_methods_description = params.multiqc_methods_description ? file(params.multiqc_methods_description, checkIfExists: true) : file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
include { INPUT_CHECK  } from '../subworkflows/local/input_check'
include { SEQTK_TRIMFQ } from '../modules//local/seqtk_trimfq/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { FASTQC  as FQRAW                            } from '../modules/nf-core/fastqc/main'
include { FASTQC as FQSORTMERNA                       } from '../modules/nf-core/fastqc/main'
include { MULTIQC                                     } from '../modules/nf-core/multiqc/main'
include { CUSTOM_DUMPSOFTWAREVERSIONS                 } from '../modules/nf-core/custom/dumpsoftwareversions/main'
include { SORTMERNA                                   } from '../modules/nf-core/sortmerna/main'
include { TRIMMOMATIC                                 } from '../modules/nf-core/trimmomatic/main'
include { FASTP                                       } from '../modules/nf-core/fastp/main'
include { FASTQC as FQTRIMMING                        } from '../modules/nf-core/fastqc/main'
include { STAR_ALIGN                                  } from '../modules/nf-core/star/align/main'
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Info required for completion email and summary
def multiqc_report = []

workflow NETSEQ {

    ch_versions = Channel.empty()

    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //
    INPUT_CHECK (
        ch_input
    )
    ch_versions = ch_versions.mix(INPUT_CHECK.out.versions)

    //
    // MODULE: Run FastQC
    //
    FQRAW (
        INPUT_CHECK.out.reads
    )
    ch_versions = ch_versions.mix(FQRAW.out.versions.first())


    //
    // MODULE: SortMeRNA
    //

    SORTMERNA (
      INPUT_CHECK.out.reads,
      ch_sortmerna_fastas
    )
     ch_versions = ch_versions.mix(SORTMERNA.out.versions.first())
    //SORTMERNA.out.log.view()

    //
    // MODULE: Run FastQC
    //

    FQSORTMERNA (
        SORTMERNA.out.reads
    )
    ch_versions = ch_versions.mix(FQSORTMERNA.out.versions.first())
    //FQSORTMERNA.out.zip.view()

    //
    // MODULE: Run Trimmomatic
    //

    TRIMMOMATIC (
      SORTMERNA.out.reads
    )
     ch_versions = ch_versions.mix(TRIMMOMATIC.out.versions.first())
    //TRIMMOMATIC.out.log.view()
    //
    //MODULE: Run FastP
    //
    //ch_adapter_fasta = Channel.fromPath(params.adapter_fasta)

    FASTP (
       TRIMMOMATIC.out.trimmed_reads,
       ch_adapter_fasta,
       params.save_trimmed_fail,
       params.save_merged
    )
    ch_versions = ch_versions.mix(FASTP.out.versions)
    //FASTP.out.log.view()
    //
    // MODULE: Run seqtktrim
    //

    SEQTK_TRIMFQ (
      FASTP.out.reads.transpose(),
      params.trim_beginning,
      params.trim_end
    )

    ch_versions = ch_versions.mix(SEQTK_TRIMFQ.out.versions)

    //
    // MODULE: Run fqtrimming
    //

    FQTRIMMING (
      SEQTK_TRIMFQ.out.reads.groupTuple()
    )
    ch_versions = ch_versions.mix(FQTRIMMING.out.versions.first())
    //FQTRIMMING.out.zip.view()
    //
    // MODULE: Run star_align
    //

    STAR_ALIGN (
      SEQTK_TRIMFQ.out.reads.groupTuple(),
      index_ch,
      gtf_ch,
      params.star_ignore_sjdbgtf,
      params.seq_platform,
      params.seq_center
    )
    ch_versions = ch_versions.mix(STAR_ALIGN.out.versions.first())
    //STAR_ALIGN.out.log_final.view()

     CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )
    //CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml.view()
    //
    // MODULE: MultiQC
    //
    workflow_summary    = WorkflowNetseq.paramsSummaryMultiqc(workflow, summary_params)
    ch_workflow_summary = Channel.value(workflow_summary)

    methods_description    = WorkflowNetseq.methodsDescriptionText(workflow, ch_multiqc_custom_methods_description)
    ch_methods_description = Channel.value(methods_description)

    ch_multiqc_files = Channel.empty()
    ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_files = ch_multiqc_files.mix(ch_methods_description.collectFile(name: 'methods_description_mqc.yaml'))
    ch_multiqc_files = ch_multiqc_files.mix(FQRAW.out.zip.collect{it[1]}.ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(SORTMERNA.out.log).collect{it[1]}.ifEmpty([])
    ch_multiqc_files = ch_multiqc_files.mix(FQSORTMERNA.out.zip.collect{it[1]}.ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(TRIMMOMATIC.out.log).collect{it[1]}.ifEmpty([])
    ch_multiqc_files = ch_multiqc_files.mix(FASTP.out.log).collect{it[1]}.ifEmpty([])
    ch_multiqc_files = ch_multiqc_files.mix(FQTRIMMING.out.zip.collect{it[1]}.ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(STAR_ALIGN.out.log_final).collect{it[1]}.ifEmpty([])
    ch_multiqc_files = ch_multiqc_files.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml.collect())


    MULTIQC (
        ch_multiqc_files.collect(),
        ch_multiqc_config.toList(),
        ch_multiqc_custom_config.toList(),
        ch_multiqc_logo.toList()
    )
    multiqc_report = MULTIQC.out.report.toList()
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    NfcoreTemplate.summary(workflow, params, log)
    if (params.hook_url) {
        NfcoreTemplate.IM_notification(workflow, params, summary_params, projectDir, log)
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
