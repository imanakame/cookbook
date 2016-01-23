#
# Cookbook Name:: cookbook
# Recipe:: default
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

execute 'wget' do
  user 'root'
  command 'yum -y install wget'
end

# httpd
execute 'httpd install' do
  user 'root'
  command 'yum -y install httpd'
end

service "httpd" do
  action :start
end

bash "phpmyadmin" do
  user 'root'
  code <<-EOC
    wget https://files.phpmyadmin.net/phpMyAdmin/4.4.14.1/phpMyAdmin-4.4.14.1-all-languages.tar.gz
    tar xvzf phpMyAdmin-4.4.14.1-all-languages.tar.gz
    mv phpMyAdmin-4.4.14.1-all-languages /vagrant_data/sites/phpmyadmin
    cp /vagrant_data/sites/phpmyadmin/config.sample.inc.php /vagrant_data/sites/phpmyadmin/config.inc.php 
    chown -R root.apache /vagrant_data/sites/phpmyadmin/ 
    chmod 660 /vagrant_data/sites/phpmyadmin/config.inc.php 
  EOC
end

# mysql
execute 'rpm mysql' do
  user 'root'
  command 'rpm -ivh http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm'
end

execute 'mysql install' do
  user 'root'
  command 'yum -y install mysql mysql-devel mysql-server'
end

service "mysqld" do
  action :start
end

# phpmyadmin
#bash "phpmyadmin" do
#  user 'root'
#  code <<-EOC
#    mysql -u root -e "set password for 'root'@'localhost' = password('');"
#  EOC
#end

# repository
bash 'add_epel' do
  user 'root'
  code <<-EOC
    rpm -Uvh http://ftp.iij.ad.jp/pub/linux/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
    #rpm -ivh http://ftp-srv2.kddilabs.jp/Linux/distributions/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
    sed -i -e "s/enabled *= *1/enabled=0/g" /etc/yum.repos.d/epel.repo
  EOC
  creates "/etc/yum.repos.d/epel.repo"
end

#bash 'add_rpmforge' do
#  user 'root'
#  code <<-EOC
#    rpm -ivh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
#    sed -i -e "s/enabled *= *1/enabled=0/g" /etc/yum.repos.d/rpmforge.repo
#  EOC
#  creates "/etc/yum.repos.d/rpmforge.repo"
#end

bash 'add_remi' do
  user 'root'
  code <<-EOC
    rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
    sed -i -e "s/enabled *= *1/enabled=0/g" /etc/yum.repos.d/remi.repo
  EOC
  creates "/etc/yum.repos.d/remi.repo"
end

bash 'yum upgrade' do
  user 'root'
  code <<-EOC
    yum -y upgrade ca-certificates --disablerepo=epel
  EOC
end

bash 'install libmcrypt-devel' do
  user 'root'
  code <<-EOC
    yum -y --enablerepo=epel install libmcrypt-devel
  EOC
end

# php install
%w[php php-devel php-common php-cli php-pear php-pdo php-mysqlnd php-xml php-process php-mbstring php-mcrypt php-pecl-xdebug].each do |p|
  package p do
    action :install
    options "--enablerepo=remi --enablerepo=remi-php56"
  end
end

# php setting
#template "php.ini" do
#  path "/etc/php.ini"
#  source "php.ini.erb"
#  mode 0644
#end

# iptable
execute 'iptable stop' do
  user 'root'
  command '/etc/rc.d/init.d/iptables stop'
end

