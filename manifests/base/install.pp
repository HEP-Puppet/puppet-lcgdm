class lcgdm::base::install () inherits lcgdm::base::params {
  Class[lcgdm::base::config] -> Class[lcgdm::base::install]

  package { 'lcgdm-libs': ensure => present; }

  if $lcgdm::base::config::egiCA and !defined(Package['ca-policy-egi-core']) {
    ensure_packages(['ca-policy-egi-core'])
  }
}
