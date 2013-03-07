#setup
package "build-essential" do
  action :install
end

user node[:redis][:user] do
  action :create
  system true
  shell "/bin/false"
end

directory node[:redis][:dir] do
  owner "root"
  mode 0755
  action :create
end

directory node[:redis][:data_dir] do
  owner node[:redis][:user]
  mode 0755
  action :create
end

directory node[:redis][:log_dir] do
  owner node[:redis][:user]
  mode 0755
  action :create
end

remote_file "#{Chef::Config[:file_cache_path]}/redis.tar.gz" do
  source "http://redis.googlecode.com/files/redis-#{node[:redis][:version]}.tar.gz"
  action :create_if_missing
end

bash "compile_redis_source" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar zxf redis.tar.gz
    cd redis-#{node[:redis][:version]}
    make && make install
  EOH
  creates "/usr/local/bin/redis-server"
end

#per port configuration

node[:redis][:ports].each do |port|
  
  directory "#{node[:redis][:data_dir]}/#{port}" do
    owner node[:redis][:user]
    mode 0755
    action :create
  end

  service "redis_#{port}" do
    provider Chef::Provider::Service::Upstart
    subscribes :restart, resources(:bash => "compile_redis_source")
    supports :restart => true, :start => true, :stop => true
  end 
    
  template "redis.conf" do
    path "#{node[:redis][:dir]}/#{port}.conf"
    source "redis.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({
     :redis_port => port
    })
    notifies :restart, resources(:service => "redis_#{port}")
  end

  template "redis.upstart.conf" do
    path "/etc/init/redis_#{port}.conf"
    source "redis.upstart.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({
     :redis_port => port
    })
    notifies :restart, resources(:service => "redis_#{port}")
  end

  service "redis_#{port}" do
    action [:enable, :start]
  end
end