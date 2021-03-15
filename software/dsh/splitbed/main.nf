// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process DSH_SPLITBED {
    tag "${meta.id}"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    conda (params.enable_conda ? "bioconda::dsh-bio=2.0" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/dsh-bio:2.0--0"
    } else {
        container "quay.io/biocontainers/dsh-bio:2.0--0"
    }

    input:
    tuple val(meta), path(bed)

    output:
    tuple val(meta), path("*.bed.gz"), emit: bed
    path "*.version.txt"             , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    dsh-split-bed \\
        $options.args \\
        -p $prefix \\
        -s '.bed.gz' \\
        -i $bed

    echo \$(dsh-bio --version 2>&1) | grep -o 'dsh-bio-tools .*' | cut -f2 -d ' ' > ${software}.version.txt
    """
}
