# nf-core/netseq: Documentation

The nf-core/netseq documentation is split into the following pages:

- [Usage](usage.md)
  - An overview of how the pipeline works, how to run it and a description of all of the different command-line flags.
- [Output](output.md)
  - An overview of the different results produced by the pipeline and how to interpret them.

  Parameters:
Sektq parameters
trim_begining and trim_end are variable that holds integer value indicating the number of nucleotides that should be trimmed from left and right end of the sequence. By default the value is set to zero, meaning any nucleotides won't be trimmed, so if you want to trim any number of nucleotides, you should define the number in the params.yml file.

Star-align:
star_ignore_sjdbgtf is assumed to be a boolean variable (true or false). It controls whether the GTF (Gene Transfer Format) file should be ignored during the STAR alignment process. The variable is used to conditionally include the --sjdbGTFfile option with the GTF file path or exclude it. By default the value of star_ignore_sjdbgtf is true so if you want to use GTF file define the value as 'False' in params.yml file.

seq_platform is a variable that holds a string indicating the sequencing platform used for generating the sequencing data. For example, it could be "illumina", "iontorrent", "pacbio", etc.The default value of seq_platform is empty,If you want the name of facility just define the parameter in params.yml file.

seq_center is a variable that holds a string representing the sequencing center or facility where the sequencing of the data was performed. It could be the name, identifier, or code of the sequencing center. by default seq_center is empty or falsy (evaluates to false),If you want the name of facility just define the parameter in params.yml file.


You can find a lot more documentation about installing, configuring and running nf-core pipelines on the website: [https://nf-co.re](https://nf-co.re)
