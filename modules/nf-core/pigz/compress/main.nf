process PIGZ_COMPRESS {
    label 'process_low'
    //stageInMode 'copy' // this directive can be set in case the original input should be kept

    conda "conda-forge::pigz"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE': //TODO add when multicontainer has been built
        'biocontainers/YOUR-TOOL-HERE' }"

    input:
    path file

    output:
    path "*.gz"        , emit: zip
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    // calling pigz -f to make it follow symlinks
    """
    pigz \\
        -p $task.cpus \\
        -f \\
        $args \\
        $file

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pigz: \$(echo \$(pigz --version 2>&1) | sed 's/^.*pigz\\w*//' ))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''

    """
    touch ${file}.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        pigz: \$(echo \$(pigz --version 2>&1) | sed 's/^.*pigz\w*//' ))
    END_VERSIONS
    """
}
