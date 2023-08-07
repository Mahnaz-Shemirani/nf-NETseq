/ Profile
profiles {

    // upsc general profile
    upsc {
        params{
            config_profile_contact = 'Mahnaz Irani_Shemirani'
            account        = 'u2021014'
	        email = 'mahnaz.irani-shemirani@umu.se'
	        mailType = 'END,FAIL'
            igenomes_base = '/mnt/picea/storage/reference'
        }
        process {
            executor       = 'slurm'
            clusterOptions = "-A '${params.account}' --mail-type '${params.mailType}' --mail-user '${params.email}'"
            memory         = { 20.GB * task.attempt }
            cpus           = { 2 * task.attempt }
            time           = { 48.h * task.attempt }
            queue          = { task.cpus > 24 ? 'big' : 'small' }
//            errorStrategy  = 'retry'
            maxRetries     = 2
        }
    }
}
