test_name "Windows Reboot Module - Pending Reboot"
extend Puppet::Acceptance::Reboot

reboot_manifest = <<-MANIFEST
reboot { 'now':
  when => pending
}
MANIFEST

pending_reboot_manifest = <<-MANIFEST
registry_key { 'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update\\RebootRequired':
  ensure => present,
}
MANIFEST

undo_pending_reboot_manifest = <<-MANIFEST
registry_key { 'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update\\RebootRequired':
  ensure => absent,
}
MANIFEST

confine :to, :platform => 'windows'

teardown do
  step "Undo the Registry Changes for Required Reboot"
  apply_manifest_on(agent, undo_pending_reboot_manifest, apply_opts)
end

windows_agents.each do |agent|
  step "Declare Reboot Required in the Registry"
  apply_manifest_on(agent, pending_reboot_manifest, apply_opts)

  step "Reboot if Pending Reboot Required"
  apply_manifest_on(agent, reboot_manifest, apply_opts)

  #Verify that a shutdown has been initiated and clear the pending shutdown.
  retry_shutdown_abort(agent)
end
