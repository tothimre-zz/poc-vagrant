$flyingwhalePath = '/var/www/flyingwhale'
$pocPath = "$flyingwhalePath/poc"
$pocCachePath = "$flyingwhalePath/poc-cache"
$pocSandboxPath = "$flyingwhalePath/poc-sandbox"
$optionablePath = "$flyingwhalePath/optionable"

vcsrepo { $pocPath:
  ensure   => present,
  provider => git,
  source   => "https://$GH_USER:$GH_PASS@github.com/flyingwhale/poc.git",
  require  => Package['git-core']
}

vcsrepo { $pocCachePath:
  ensure   => present,
  provider => git,
  source   => "https://$GH_USER:$GH_PASS@github.com/flyingwhale/poc-cache.git",
  require  => Package['git-core']
}

vcsrepo { $pocSandboxPath:
  ensure   => present,
  provider => git,
  source   => "https://$GH_USER:$GH_PASS@github.com/flyingwhale/poc-cache.git",
  require  => Package['git-core']
}

vcsrepo { $optionablePath:
  ensure   => present,
  provider => git,
  source   => "https://$GH_USER:$GH_PASS@github.com/flyingwhale/optionable.git",
  require  => Package['git-core']
}

composer::run { 'composerPoc':
   path => $pocPath,
   require => [Vcsrepo[$pocPath],Class[composer]],
}

composer::run { 'composerSandbox':
   path => $pocSandboxPath,
   require => [Vcsrepo[$pocSandboxPath],Class[composer]],
}

composer::run { 'composerOptionable':
   path => $optionablePath,
   require => [Vcsrepo[$optionablePath],Class[composer]],
}

composer::run { 'composerPocCache':
   path => $pocCachePath,
   require => [Vcsrepo[$pocPath],Class[composer]],
}

exec{ 'poc db create': 
	command => 'mysql -u root -e "create database poc_tests"',
	require  => Package['mysql-server'],
}

exec{ 'poc db init': 
	command => "console poc:db:init -n ",
	require => [Package['mysql-server'],Exec['poc db create']],
	path    => "$pocPath/bin/:/usr/bin/"
}

exec{ 'install php mongo': 
	command => "pecl install mongo",
	require => [Package['php5-dev',mongodb]],
}

exec{ 'add php.init mongo': 
	command => 'echo "extension=mongo.so" >> /etc/php5/cli/php.ini',
	require => Exec['install php mongo']
}


/*
exec{ 'poc phpunit': 
	command => "phpunit",
	require => Exec['poc db init'],
	path    => "$pocPath/bin/:/usr/bin/"
}
*/

exec { 'git stuff':
	command => "git config --global user.name '$GIT_USER';git config --global user.email $GIT_EMAIL;git config --global core.editor vim;git config --global merge.tool vimdiff",
	require  => Package['git-core'],
}
