$pocPath = '/var/www/poc'

vcsrepo { $pocPath:
  ensure   => present,
  provider => git,
  source   => "https://$GH_USER:$GH_PASS@github.com/FlyingWhale/poc.git",
  require  => Package['git-core']
}

composer::run { 'composer':
   path => $pocPath,
   require => [Vcsrepo[$pocPath],Class[composer]],
}

exec{ 'poc db create': 
	command => 'mysql -u root -e "create database poc_testsasdffdga"',
	require  => Package['mysql-server'],
}

exec{ 'poc db init': 
	command => "console poc:db:init -n ",
	require => [Package['mysql-server'],Exec['poc db create']],
	path    => "$pocPath/bin/:/usr/bin/"
}

/*
exec{ 'poc phpunit': 
	command => "phpunit",
	require => Exec['poc db init'],
	path    => "$pocPath/vendor/bin/:/usr/bin/"
}
*/

exec { 'git stuff':
	command => "git config --global user.name '$GIT_USER';git config --global user.email $GIT_EMAIL;git config --global core.editor vim;git config --global merge.tool vimdiff",
	require  => Exec['poc db init'],
}
