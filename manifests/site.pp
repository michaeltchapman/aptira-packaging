node default {
   $role = 'packaging'
   site::role{ $role: }
}

define site::role
{

  $node_classes = hiera("${name}_classes", '')
  if $node_classes {
    include $node_classes
    $s = join($node_classes, ' ')
    notice("Including node classes : ${s}")
  }
}
