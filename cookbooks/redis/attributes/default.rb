default[:redis][:dir]       = "/etc/redis"
default[:redis][:data_dir]  = "/var/lib/redis" 
default[:redis][:log_dir]   = "/var/log/redis"
# one of: debug, verbose, notice, warning
default[:redis][:loglevel]  = "notice"
default[:redis][:user]      = "redis"
default[:redis][:ports]     = [6379,7379]
default[:redis][:bind]      = "127.0.0.1"
default[:redis][:version]   = "2.6.10"
