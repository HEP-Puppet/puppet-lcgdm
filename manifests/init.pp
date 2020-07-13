class lcgdm (
  String $dbuser,
  String $dbpass,
  String $domain,
  Array[String] $volist,
  String $flavor = 'dpns',
  String $dbflavor = 'mysql',
  Stdlib::Host $dbhost = 'localhost',
  String $dpm_db = 'dpm_db',
  String $ns_db = 'cns_db',
  String $mysqlrootpass = '',
  Enum['yes', 'no'] $coredump = 'no',
  Boolean $dbmanage = true,
  Optional[Integer] $uid = undef,
  Optional[Integer] $gid = undef,
) {
  Class[lcgdm::ns::service] -> Class[lcgdm::dpm::service]
  Class[lcgdm::ns::service] -> Class[lcgdm::ns::client]
  Class[lcgdm::dpm::service] -> Lcgdm::Ns::Domain <| |>
  Lcgdm::Ns::Domain <| |> -> Lcgdm::Ns::Vo <| |>

  #
  # Base configuration
  #
  if !defined(Class['lcgdm::base']) {
    if gid != undef {
      class { 'lcgdm::base':
        uid => $uid,
        gid => $gid,
      }
    } else {
      class { 'lcgdm::base':
        uid => $uid,
        gid => $uid,
      }
    }

  }

  #
  # In case the DB is not local we should configure the file /root/.my.cnf

  if $dbhost != 'localhost' and $dbhost != $::fqdn and $dbmanage and $dbflavor == 'mysql'{
    #check if root pass is empty
    if empty($mysqlrootpass ) {
      fail('mysqlrootpass parameter  should  not be empty')
    }
    #create the /root/.my.cnf
    file { '/root/.my.cnf':
      ensure  => present,
      mode    => '0655',
      content => template('lcgdm/mysql/my.cnf.erb'),
      before  => [ Class[lcgdm::ns::install], Class[lcgdm::dpm::install] ]
    }
  }

  #
  # Nameserver client and server configuration.
  #
  if gid != undef {
    class { 'lcgdm::ns':
      flavor   => $flavor,
      dbflavor => $dbflavor,
      dbuser   => $dbuser,
      dbpass   => $dbpass,
      dbhost   => $dbhost,
      ns_db    => $ns_db,
      coredump => $coredump,
      dbmanage => $dbmanage,
      uid      => $uid,
      gid      => $gid,
    }
  } else {
    class { 'lcgdm::ns':
      flavor   => $flavor,
      dbflavor => $dbflavor,
      dbuser   => $dbuser,
      dbpass   => $dbpass,
      dbhost   => $dbhost,
      ns_db    => $ns_db,
      coredump => $coredump,
      dbmanage => $dbmanage,
      uid      => $uid,
      gid      => $uid,
    }
  }

  #
  # DPM daemon configuration.
  #
  class { 'lcgdm::dpm':
    dbflavor => $dbflavor,
    dbuser   => $dbuser,
    dbpass   => $dbpass,
    dbhost   => $dbhost,
    dpm_db   => $dpm_db,
    coredump => $coredump,
    dbmanage => $dbmanage,
  }

  #
  # Create path for domain and VOs to be enabled.
  #
  lcgdm::ns::domain { $domain: }

  lcgdm::ns::vo { $volist: domain => $domain, }
}
