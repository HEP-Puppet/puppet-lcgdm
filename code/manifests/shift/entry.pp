define lcgdm::shift::entry($component, $type) {

    augeas { "shiftentry_${component}-${type}":
      context => "/files/etc/shift.conf",
      changes => [
        "rm name[.='$component'][type='$type']",
        "set name[last()+1] $component",
        "set name[last()]/type $type",
    ],
      require => [ File["/usr/share/augeas/lenses/dist/shift.aug"], File["/etc/shift.conf"], ],
    }

}
