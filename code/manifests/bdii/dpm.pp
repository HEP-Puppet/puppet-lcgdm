class lcgdm::bdii::dpm (
  $sitename = undef,
  $basedir  = "home",
  $vos      = [],
  $glue2    = true,
  $dpm_host = $lcgdm::dpm::config::host,
) {
  Class[Lcgdm::Dpm::Config] -> Class[Lcgdm::Bdii::Dpm]

  file {"/var/lib/bdii/gip/provider/se-dpm":
    owner => root,
    group => root,
    mode  => 755,
    content => inline_template("
export X509_USER_CERT=/var/lib/ldap/hostcert.pem
export X509_USER_KEY=/var/lib/ldap/hostkey.pem
dpm-listspaces --gip --protocols --basedir <%= @basedir %> --site <%= @sitename %><% if @glue2 %> --glue2<% end %>
    ")
  }

  file {"/var/lib/bdii/gip/provider/service-srm2.2":
    owner => root,
    group => root,
    mode  => 755,
    content => inline_template("
glite-info-service /var/lib/bdii/gip/glite-info-service-srm2.2.conf <%= @sitename %> httpg://<%= @dpm_host %>:8446/srm/managerv2
    ")
  }

  file {"/var/lib/bdii/gip/glite-info-service-srm2.2.conf":
    owner => root,
    group => root,
    mode  => 755,
    content => inline_template("
init = glite-info-service-dpm init v2
service_type = SRM
get_version = echo \$GLITE_INFO_SERVICE_VERSION
get_endpoint = echo \$GLITE_INFO_SERVICE_ENDPOINT
get_status = glite-info-service-test SRM_V2 && glite-info-service-dpm status v2
WSDL_URL = http://sdm.lbl.gov/srm-wg/srm.v2.2.wsdl
semantics_URL = http://sdm.lbl.gov/srm-wg/doc/SRM.v2.2.html
get_starttime = perl -e '@st=stat(\"/var/run/dpm.pid\");print \"@st[10]\\n\";'
get_data = echo
get_services = echo
get_owner = <% vos.sort.each do |vo| %> echo <%= vo %>; <% end %>
get_acbr = <% vos.sort.each do |vo| %> echo VO:<%= vo %>; <% end %>
    ")
  }

  # Required for dpm-listspaces
  package{"dpm-python":}
  # Required for srm provider
  package{"glite-info-provider-service":}

  # dpm-listspaces need hostcert and key to be able to
  # connect (it is running as the ldap user)
  file{"/var/lib/ldap/hostcert.pem":
       ensure => present,
       source => "/etc/grid-security/hostcert.pem",
       owner  => "ldap",
       group  => "ldap"
  }
  file{"/var/lib/ldap/hostkey.pem":
       ensure => present,
       mode   => 0400,
       source => "/etc/grid-security/hostkey.pem",
       owner  => "ldap",
       group  => "ldap"
  }
}

